//
//  CSRPTailorAdNode+BuiltIn.m
//
#import "CSRPTailorAdNode+BuiltIn.h"
#import "CSRPAdEventTypeRegistry.h"

@implementation CSRPTailorAdNode (BuiltIn)

- (NSArray<id<CSRPTailorEventLike>> *)eventLikes {
    return self->_eventLikes = self->_eventLikes ?: self.pr_eventLikes;
}

typedef NSArray<id<CSRPTailorEventLike>>    EvLikeArray;

static EvLikeArray* pr_filterEvents(EvLikeArray* array) {
    NSMutableArray* const result = NSMutableArray.new;
    for (id<CSRPTailorEventLike> ev in array) {
        if (ev.eventEntry)
            [result addObject:ev];
    }
    return result.copy;
}

- (EvLikeArray*)pr_eventLikes {
    EvLikeArray* builtIns = [CSRPTailorBuiltInEvent eventLikesWithTimeRange:self.timeRange];
    EvLikeArray* trakings = pr_filterEvents(self.trackingEvents);
    if (!builtIns.count) return trakings;
    if (!trakings.count) return builtIns;
    return [trakings arrayByAddingObjectsFromArray:builtIns];
}

@end

@implementation CSRPTailorBuiltInEvent
@synthesize timeRange;
@synthesize eventEntry;

struct MixingRate {
    int lower, upper;
};
struct EventTypeMixingRates {
    CSRPAdEventTypeEnum eventType;
    struct MixingRate rate;
};
struct EventTypeMixingRates const s_injections[] = {
//  { CSRPAdEventType_impression,       {1, 0}},
    { CSRPAdEventType_start,            {1, 0}},
    { CSRPAdEventType_firstQuartile,    {3, 1}},
    { CSRPAdEventType_midpoint,         {1, 1}},
    { CSRPAdEventType_thirdQuartile,    {1, 3}},
    { CSRPAdEventType_complete,         {0, 1}},
    CSRPAdEventType_NOTHING     // terminator
};

+ (NSArray<id<CSRPTailorEventLike>> *)eventLikesWithTimeRange:(CSRPNumberRange *)range {
    double const lower = range.lower.doubleValue;
    double const upper = range.upper.doubleValue;
    CSRPAdEventTypeRegistry* const registry = CSRPAdEventTypeRegistry.sharedRegistry;
    NSMutableArray* const result = NSMutableArray.new;{
        CSRPTailorBuiltInEvent* const ev = CSRPTailorBuiltInEvent.new;
        ev->timeRange = range;
        ev->eventEntry = [registry builtInEntryAt:CSRPAdEventType_impression];
        [result addObject:ev];
    }
    struct EventTypeMixingRates const* it = s_injections;
    for (; it->eventType != CSRPAdEventType_NOTHING; ++it) {
        NSNumber* const mixed = @(
            (lower * it->rate.lower + upper * it->rate.upper)
            / (it->rate.lower + it->rate.upper)
        );
        CSRPTailorBuiltInEvent* const ev = CSRPTailorBuiltInEvent.new;
        ev->timeRange = [CSRPNumberRange rangeWithLower:mixed upper:mixed];
        ev->eventEntry = [registry builtInEntryAt:it->eventType];
        [result addObject:ev];
    }
    return result.copy;
}

@end
