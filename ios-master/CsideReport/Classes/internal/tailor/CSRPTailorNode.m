//
//  CSRPTailorNode.m
//
#import "CSRPTailorNode.h"
#import "CSRPTailorAdNode+BuiltIn.h"
#import "CSRPTailorSchema.h"

@implementation CSRPTailorNode

static CSRPNumberRange* pr_timeRange(NSDictionary* dic) {
    NSNumber* const du = dic[CSRPTailorSchemaLabels.durationInSeconds];
    NSNumber* const st = dic[CSRPTailorSchemaLabels.startTimeInSeconds];
    if (!st)
        return nil;
    double const up = st.doubleValue + du.doubleValue;
    return [CSRPNumberRange rangeWithLower:st upper:@(up)];
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (!dic)
        return nil;
    self = [super init];
    if (self) {
        self->_timeRange = pr_timeRange(dic);
        self->_dic = dic;
    }
    return self;
}

static NSArray* pr_arrayOfNodes(Class clazz, NSArray* raws) {
    NSMutableArray* const result = NSMutableArray.new;
    for (NSDictionary* dic in raws) {
        [result addObject:[[clazz alloc] initWithDictionary:dic]];
    }
    return result.copy;
}

@end

@implementation CSRPTailorEventNode {
    CSRPAdEventTypeEntry* _eventEntry;
}
- (CSRPAdEventTypeEntry *)eventEntry {
    return self->_eventEntry = self->_eventEntry ?:
        CSRPAdEventTypeRegistry.sharedRegistry[self.eventType];
}
- (NSString *)eventType { return self.dic[CSRPTailorSchemaLabels.eventType]; }
- (NSArray<NSString *> *)beaconUrls { return self.dic[CSRPTailorSchemaLabels.beaconUrls]; }
@end

@implementation CSRPTailorAdNode {
    NSArray<CSRPTailorEventNode*>* _eventNodes;
}
- (NSArray<CSRPTailorEventNode *> *)trackingEvents {
    return self->_eventNodes = self->_eventNodes ?:
        pr_arrayOfNodes(CSRPTailorEventNode.class, self.dic[CSRPTailorSchemaLabels.trackingEvents]);
}
- (NSString *)adId { return self.dic[CSRPTailorSchemaLabels.adId]; }
- (NSString *)vastAdId { return self.dic[CSRPTailorSchemaLabels.vastAdId]; }
- (CSRPAdLid *)localId {
    return self.timeRange.lower;
}
@end

@implementation CSRPTailorAvailNode {
    NSArray<CSRPTailorAdNode*>* _adNodes;
}
- (NSArray<CSRPTailorAdNode *> *)ads {
    return self->_adNodes = self->_adNodes ?:
        pr_arrayOfNodes(CSRPTailorAdNode.class, self.dic[CSRPTailorSchemaLabels.ads]);
}
@end

@implementation CSRPTailorRootNode {
    NSArray<CSRPTailorAvailNode*>* _availNodes;
}
- (NSArray<CSRPTailorAvailNode *> *)avails {
    return self->_availNodes = self->_availNodes ?:
        pr_arrayOfNodes(CSRPTailorAvailNode.class, self.dic[CSRPTailorSchemaLabels.avails]);
}
@end
