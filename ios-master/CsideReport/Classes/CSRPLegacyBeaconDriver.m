//
//  CSRPLegacyBeaconDriver.m
//
#import "CSRPLegacyBeaconDriver.h"

@implementation CSRPLegacyBeaconDriver

- (instancetype)init {
    return self = [super init];
}

- (NSDictionary *)mergedDictionaryWithParams:(NSDictionary *)params {
    NSMutableDictionary* result = (self.params ?: @{}).mutableCopy;
    [result addEntriesFromDictionary:params ?: @{}];
    return result;
}

- (void)dispatchWithAdditionalParams:(NSDictionary *)params {
    NSURLComponents* const compo = [self.urlGenerator urlComponents];
    if (!compo)
        return;
    NSMutableArray<NSURLQueryItem*>* const items = (compo.queryItems ?: @[]).mutableCopy;
    NSDictionary* const queries = [self mergedDictionaryWithParams:params];
    for (NSString* key in queries)
        [items addObject:[NSURLQueryItem queryItemWithName:key value:queries[key]]];
    compo.queryItems = items;
    [self.dispatcher postBeaconToUrl:compo.URL];
}

#pragma mark - protocol CSRPLegacyBeaconDriver

- (void)trackWithSeconds:(Float64)seconds player:(id<CSRPTrackingPlayerLike>)player {
    // do nothing
}
- (void)trackWithEvent:(id)event ofAd:(id)ad player:(id<CSRPTrackingPlayerLike>)player {
    // do nothing
}
- (void)trackWithAction:(NSString *)action adId:(NSString *)adId player:(id<CSRPTrackingPlayerLike>)player {
    // do nothing
}

@end
