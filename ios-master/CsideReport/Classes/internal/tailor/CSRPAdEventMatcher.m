//
//  CSRPAdEventMatcher.m
//
#import "CSRPAdEventMatcher.h"
#import "CSRPFiredAdEvents.h"
#import "CSRPPositionHistory.h"

@implementation CSRPAdEventMatcher {
    CSRPPositionHistory* _history;
    NSDictionary<CSRPAdLid*, CSRPFiredAdEvents*>* _firedAds;
    CSRPTailorRootNode* _rootNode;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self->_history = CSRPPositionHistory.new;
        self->_firedAds = @{};
    }
    return self;
}

- (void)setParsedJson:(NSDictionary *)parsedJson {
    if (self->_parsedJson == parsedJson || !parsedJson)
        return;
    self->_rootNode = [CSRPTailorRootNode.alloc initWithDictionary:parsedJson];
    self->_parsedJson = parsedJson;
}

static NSComparisonResult pr_compareLower(CSRPNumberRange* r1, CSRPNumberRange* r2) {
    if (r1 == r2) return NSOrderedSame;
    NSNumber* const low1 = r1.lower;
    NSNumber* const low2 = r2.lower;
    if (!low1 && low2) return NSOrderedAscending;
    if (low1 && !low2) return NSOrderedDescending;
    return [low1 compare:low2];
}
static NSArray<CSRPFiringEventItem*>* pr_sorted(NSArray<CSRPFiringEventItem*>* items) {
    return [items sortedArrayUsingComparator:^(id obj1, id obj2){
        CSRPFiringEventItem* const i1 = obj1;
        CSRPFiringEventItem* const i2 = obj2;
        id<CSRPTailorEventLike> const ev1 = i1.event;
        id<CSRPTailorEventLike> const ev2 = i2.event;
        NSComparisonResult const evC = pr_compareLower(ev1.timeRange, ev2.timeRange);
        if (evC != NSOrderedSame) return evC;
        NSComparisonResult const adC = pr_compareLower(i1.ad.timeRange, i2.ad.timeRange);
        if (adC != NSOrderedSame) return adC;
        NSUInteger const uid1 = ev1.eventEntry.uniqueId;
        NSUInteger const uid2 = ev2.eventEntry.uniqueId;
        if (uid1 < uid2) return NSOrderedAscending;
        if (uid1 > uid2) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

static NSArray<CSRPFiringEventItem*>*
pr_collectIntersectings(CSRPTailorRootNode* rootNode, double duration, double endTime) {
    CSRPNumberRange* const timeRange = [CSRPNumberRange rangeWithLower:@(endTime - duration) upper:@(endTime)];
    int (^intersects)(CSRPNumberRange*) = ^(CSRPNumberRange* range) {
        CSRPNumberRange* x = [timeRange intersectWithRange:range];
        return x.lower <= x.upper;
    };
    NSMutableArray<CSRPFiringEventItem*>* const result = NSMutableArray.new;
    for (CSRPTailorAvailNode* const avail in rootNode.avails) {
        if (!intersects(avail.timeRange)) continue;
        for (CSRPTailorAdNode* const ad in avail.ads) {
            if (!intersects(ad.timeRange)) continue;
            for (id<CSRPTailorEventLike> const ev in ad.eventLikes) {
                if (!intersects(ev.timeRange)) continue;
                [result addObject:[CSRPFiringEventItem.alloc initWithAd:ad event:ev]];
            }
        }
    }
    return result.copy;
}

static NSDictionary<CSRPAdLid*, CSRPFiredAdEvents*>*
pr_discardOutdated(double timeout, NSDictionary<CSRPAdLid*, CSRPFiredAdEvents*>* dic) {
    double const timeLimit = CSRPPositionHistory_LogEntry.elapsedTime - timeout;
    NSMutableDictionary* result = nil;
    for (CSRPFiredAdEvents* value in dic.allValues.copy) {
        if (value.updatedAt < timeLimit) {
            result = result ?: dic.mutableCopy;
            [result removeObjectForKey:value.adLid];
        }
    }
    return result.copy ?: dic;
}

- (NSArray<CSRPFiringEventItem *> *)matchedEventsAtSeconds:(Float64)seconds {
    [self->_history addEntryWithPosition:seconds];
    self->_firedAds = pr_discardOutdated(60*5, self->_firedAds);
    return [self pr_matchedEventsNear:pr_collectIntersectings(self->_rootNode, 30, seconds)];
}

- (NSArray<CSRPFiringEventItem*>*)pr_matchedEventsNear:(NSArray<CSRPFiringEventItem*>*)nearbys {
    NSMutableArray<CSRPFiringEventItem*>* const result = NSMutableArray.new;
    NSMutableDictionary<CSRPAdLid*, CSRPFiredAdEvents*>* updatedAds = nil;
    for (CSRPFiringEventItem* const item in nearbys) {
        id<CSRPTailorEventLike> const event = item.event;
        CSRPAdEventTypeEntry* const eventEntry = event.eventEntry;
        CSRPAdLid* const adLid = item.ad.localId;
        CSRPFiredAdEvents* const firedAdEv =
            (updatedAds ?: self->_firedAds)[adLid]
            ?: [CSRPFiredAdEvents.alloc initWithAdLid:adLid];
        if ([firedAdEv wildlyMatchesWithEvent:eventEntry])
            continue;
        NSNumber* const entryNum = [self->_history primaryEntriesWithRange:event.timeRange].lastObject;
        if (!entryNum)
            continue;
        double const createdAt = self->_history[entryNum.intValue].createdAt;
        CSRPFiredAdEvents* const updated = [firedAdEv updatedWithEvent:eventEntry logAt:createdAt];
        if (!updated)
            continue;
        updatedAds = updatedAds ?: self->_firedAds.mutableCopy;
        updatedAds[adLid] = updated;
        [result addObject:item];
    }
    self->_firedAds = updatedAds.copy ?: self->_firedAds;
    return pr_sorted(result);
}

- (NSString *)updatedAdIdAtSeconds:(Float64)seconds eventSink:(id<CSRPAdEventSink>)sink {
    NSArray<CSRPFiringEventItem*>* const items = [self matchedEventsAtSeconds:seconds];
    if (items.count) NSLog(@"%s: %@", __func__, items);
    for (CSRPFiringEventItem* const it in items) {
        [it fireToSink:sink];
    }
    NSString* const adId = items.lastObject.ad.vastAdId;
    return adId.length ? adId : nil;
}

@end

@implementation CSRPFiringEventItem

- (instancetype)initWithAd:(CSRPTailorAdNode *)ad event:(id<CSRPTailorEventLike>)event {
    self = [super init];
    if (self) {
        self->_ad = ad;
        self->_event = event;
    }
    return self;
}

- (void)fireToSink:(id<CSRPAdEventSink>)sink {
    CSRPAdEventTypeEntry* const entry = self->_event.eventEntry;
    if (entry.isBuiltIn) {
        return [sink.actionTracker trackEvent:entry ofAd:self->_ad];
    }
    id<CSRPBeaconDispatcher> const beaconDispatcher = sink.beaconDispatcher;
    NSAssert([self->_event isKindOfClass:CSRPTailorEventNode.class], @"assume class CSRPTailorEventNode");
    CSRPTailorEventNode* const node = self->_event;
    for (NSString* const string in node.beaconUrls) {
        if (!string.length)
            continue;
        NSURL* const url = [NSURL URLWithString:string];
        if (url)
        {
            [beaconDispatcher postBeaconToUrl:url];
        }
        else
        {
            NSLog(@"no url: %@", string);
        }
    }
}

- (NSString *)description {
    CSRPAdEventTypeEntry* const entry = self->_event.eventEntry;
    return [NSString stringWithFormat:@"%@: %@=%@:%@ %@=%@:%@:%@", @"CSRPFiringEventItem",
            @"ad", self->_ad.vastAdId, self->_ad.localId,
            @"event", self->_event.timeRange.lower, @(entry.uniqueId), entry.name];
}

@end
