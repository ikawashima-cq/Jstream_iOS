//
//  CSRPBeaconUrlSet.m
//
#import "CSRPBeaconUrlSet.h"
#import "CSRPLegacyBeaconFactory.h"

@implementation CSRPBeaconUrlSet

- (NSDictionary<NSString *,NSString *> *)dictionaryForFactory {
    struct CSRPLegacyBeaconFactoryLabels const*const s = &CSRPLegacyBeaconFactoryLabels;
    NSMutableDictionary* const map = [NSMutableDictionary new];
    [map setValue:self.vr_live_video forKey:s->VRLiveVideoBeacon];
    [map setValue:self.vr_live_ad forKey:s->VRLiveAdBeacon];
    [map setValue:self.jst_ad forKey:s->JstAdBeacon];
    [map setValue:self.jst_video forKey:s->JstLiveBeacon];
    [map setValue:self.jst_trace forKey:s->JstTraceBeacon];
    return map.copy;
}

- (NSArray<id<CSRPLegacyBeaconDriver>> *)driversFromFactory:(CSRPLegacyBeaconFactory *)factory {
    NSDictionary<NSString*, NSString*>* const strings = self.dictionaryForFactory;
    NSMutableArray<CSRPLegacyBeaconDriver*>* const result = [NSMutableArray new];
    for (NSString* key in strings.allKeys) {
        CSRPLegacyBeaconDriver* driver = [factory driverWithLabel:key];
        if (driver) {
            driver.urlGenerator = [factory.class urlGeneratorFromString:strings[key] forLabel:key];
            [result addObject:driver];
        }
    }
    return result.copy;
}

@end
