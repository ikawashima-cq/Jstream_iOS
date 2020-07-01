//
//  CSRPLegacyBeaconFactory.m
//
#import "CSRPLegacyBeaconFactory.h"
#import "CSRPDynamicNamedUrl.h"
#import "CSRPBeaconParamConfig.h"

struct CSRPLegacyBeaconFactoryLabels const CSRPLegacyBeaconFactoryLabels = {
    .VRLiveAdBeacon     = @"VRLiveAdBeacon",
    .VRLiveVideoBeacon  = @"VRLiveVideoBeacon",
    .JstAdBeacon        = @"JstAdBeacon",
    .JstLiveBeacon      = @"JstLiveBeacon",
    .JstTraceBeacon     = @"JstTraceBeacon",
};

static NSArray<NSString*>* pr_arrayOfLabels() {
    struct CSRPLegacyBeaconFactoryLabels const*const s = &CSRPLegacyBeaconFactoryLabels;
    static NSArray<NSString*>* s_v = nil;
    if (!s_v) s_v =
        @[
          s->VRLiveAdBeacon,
          s->VRLiveVideoBeacon,
          s->JstAdBeacon,
          s->JstLiveBeacon,
          s->JstTraceBeacon,
          ];
    return s_v;
}

static NSString* pr_labelMatched(NSString* name) {
    for (NSString* i in pr_arrayOfLabels()) {
        if ([i isEqualToString:name])
            return i;
    }
    return nil;
}

#pragma mark -

static NSMutableDictionary<NSString*, NSString*>*
pr_collectItems(
                NSDictionary<NSString*, NSString*>* map,
                NSArray<NSString*>* keys
                ) {
    NSMutableDictionary<NSString*, NSString*>* const result = [NSMutableDictionary new];
    for (NSString* const i in keys) {
        [result setValue:map[i] forKey:i];
    }
    return result;
}

static NSString* pr_intervalSince1970(NSDate* date) {
    long time = date.timeIntervalSince1970;
    return [NSString stringWithFormat:@"%@", @(time)];
}
static NSString* pr_currentDate(id<CSRPTrackingPlayerLike> player) {
    return pr_intervalSince1970(player.currentDate);
}

#pragma mark -
@interface CSRPLegacyJstAdBeacon : CSRPLegacyBeaconDriver
@end
@implementation CSRPLegacyJstAdBeacon
- (void)trackWithEvent:(id<CSRPAdEventTypeEntry>)event ofAd:(id<CSRPTailorAdBasis>)ad player:(id<CSRPTrackingPlayerLike>)player {
    if (event.is_start)
        [self dispatchWithAdditionalParams:
         @{
           @"cmid": ad.vastAdId,
           }];
}
- (void)trackWithAction:(NSString *)action adId:(NSString *)adId player:(id<CSRPTrackingPlayerLike>)player {
    if ([action isEqualToString:@"start"])
        [self dispatchWithAdditionalParams:
         @{
           @"cmid": adId,
           }];
}
@end

#pragma mark -
@interface CSRPLegacyJstTraceBeacon : CSRPLegacyBeaconDriver
@end
@implementation CSRPLegacyJstTraceBeacon
- (void)trackWithEvent:(id<CSRPAdEventTypeEntry>)event ofAd:(id<CSRPTailorAdBasis>)ad player:(id<CSRPTrackingPlayerLike>)player {
    if (event.is_start || event.is_complete)
        [self dispatchWithAdditionalParams:
         @{
           @"beacontype": @"jst_trace",
           @"adId": ad.adId,
           @"vastAdId": ad.vastAdId,
           @"eventType": event.name,
           }];
}
- (void)trackWithAction:(NSString *)action adId:(NSString *)adId player:(id<CSRPTrackingPlayerLike>)player {
    NSString* event = nil; {
        if ([action isEqualToString:@"start"])
            event = action;
        else if ([action isEqualToString:@"complete"])
            event = action;
    }
    if (event)
        [self dispatchWithAdditionalParams:
         @{
           @"cmid": adId,
           @"eventType": event,
           }];
}
@end

#pragma mark -
@interface CSRPLegacyVRLiveAdBeacon : CSRPLegacyBeaconDriver
@end
@implementation CSRPLegacyVRLiveAdBeacon
- (void)trackWithEvent:(id<CSRPAdEventTypeEntry>)event ofAd:(id<CSRPTailorAdBasis>)ad player:(id<CSRPTrackingPlayerLike>)player {
    [self trackWithAction:event.name adId:ad.vastAdId player:player];
}
- (void)trackWithAction:(NSString *)action adId:(NSString *)adId player:(id<CSRPTrackingPlayerLike>)player {
    struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
    NSDictionary<NSString*, NSString*>* rates = nil; {
        if ([action isEqualToString:@"start"])
            rates = @{
                      //K->vr_opt4: @"pre",
                      K->vr_opt4: @"mid",
                      K->vr_opt5: @"0",
                      };
        else if ([action isEqualToString:@"complete"])
            rates = @{
                      K->vr_opt4: @"mid",
                      K->vr_opt5: @"100",
                      };
    }
    if (!rates)
        return;
    NSMutableDictionary<NSString*, NSString*>* const params = rates.mutableCopy;
    
    NSString *tmpopt17 = @"0";
    long ioscurrenttime = [[NSDate date] timeIntervalSince1970];
    long videocurrenttime = player.currentDate.timeIntervalSince1970;
    long timediff = ioscurrenttime - videocurrenttime;

    NSLog(@"ioscurrenttime: %@", [NSString stringWithFormat:@"%@", @(ioscurrenttime)]);
    NSLog(@"videocurrenttime: %@", [NSString stringWithFormat:@"%@", @(videocurrenttime)]);
    NSLog(@"timediff: %@", [NSString stringWithFormat:@"%@", @(timediff)]);

    if(timediff > DVRJudgeDiffUnixTime)
    {
        tmpopt17 = @"1";
    }
    
    [params addEntriesFromDictionary:
     @{
       K->vr_opt3: adId ?: @"",
       K->vr_opt16: pr_currentDate(player),
       K->vr_opt17: tmpopt17,
       }];
    [self dispatchWithAdditionalParams:params];
}
- (void)setParams:(NSDictionary<NSString *,NSString *> *)params {
    struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
    NSArray<NSString*>* const copies =
    @[
      K->vr_tagid1, K->vr_tagid2, K->id1, K->url,
      K->vr_opt2, K->vr_opt6, K->vr_opt8, K->vr_opt10,
      /* K->vr_opt5, */ K->vr_opt15,
      ];
    NSMutableDictionary<NSString*, NSString*>* const res = pr_collectItems(params, copies);
    [res setValue:params[K->vr_opt1] forKey:K->vr_opt1];    // @"live-ad"
    [super setParams:res];
}
@end

#pragma mark -
@interface CSRPLegacyVRLiveVideoBeacon : CSRPLegacyBeaconDriver
@end
@implementation CSRPLegacyVRLiveVideoBeacon {
    long _last;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        _last = -1;
    }
    return self;
}
- (void)trackWithSeconds:(Float64)seconds player:(id<CSRPTrackingPlayerLike>)player {
    struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
    long const every = 60;  // 1 minute
    long const current = seconds;
    long const last = _last;
    _last = current;
    NSString* event = nil; {
        if (last < 0)
            event = @"start";
        else if (last / every != current / every)
            event = @"loop";
    }
    
    NSString *tmpopt17 = @"0";
    long ioscurrenttime = [[NSDate date] timeIntervalSince1970];
    long videocurrenttime = player.currentDate.timeIntervalSince1970;
    long timediff = ioscurrenttime - videocurrenttime;

    NSLog(@"ioscurrenttime: %@", [NSString stringWithFormat:@"%@", @(ioscurrenttime)]);
    NSLog(@"videocurrenttime: %@", [NSString stringWithFormat:@"%@", @(videocurrenttime)]);
    NSLog(@"timediff: %@", [NSString stringWithFormat:@"%@", @(timediff)]);

    if(timediff > DVRJudgeDiffUnixTime)
    {
        tmpopt17 = @"1";
    }

    if (event)
        [self dispatchWithAdditionalParams:
         @{
         //K->vr_opt3: pr_intervalSince1970([NSDate date]),
           K->vr_opt7: event,
           K->vr_opt16: pr_currentDate(player),
           K->vr_opt17: tmpopt17,
           }];
}
- (void)setParams:(NSDictionary<NSString *,NSString *> *)params {
    struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
    NSArray<NSString*>* const copies =
    @[
      K->vr_tagid1, K->vr_tagid2, K->id1, K->url,
      K->vr_opt2, K->vr_opt6, K->vr_opt8, K->vr_opt10,
      K->vr_opt5, /* K->vr_opt15, */
      ];
    NSMutableDictionary<NSString*, NSString*>* const res = pr_collectItems(params, copies);
    res[K->vr_opt1] = @"live-movie";
    [super setParams:res];
}
@end

#pragma mark -
@interface CSRPLegacyJstLiveBeacon : CSRPLegacyBeaconDriver
@end
@implementation CSRPLegacyJstLiveBeacon {
    long _last;
}
- (void)trackWithSeconds:(Float64)seconds player:(id<CSRPTrackingPlayerLike>)player {
    long const last = _last;
    _last = 1;
    if (!last)
        [self dispatchWithAdditionalParams:@{}];
}
@end

#pragma mark -
@implementation CSRPLegacyBeaconFactory

+ (NSArray<NSString *> *)arrayOfLabels {
    return [pr_arrayOfLabels() copy];
}

+ (id<CSRPUrlGenerator>)urlGeneratorFromString:(NSString *)string forLabel:(NSString *)label {
    struct CSRPLegacyBeaconFactoryLabels const*const s = &CSRPLegacyBeaconFactoryLabels;
    NSString* const sym = pr_labelMatched(label);
    if (!sym)
        return nil;
    if (sym == s->VRLiveAdBeacon || sym == s->VRLiveVideoBeacon)
        return [CSRPDynamicNamedUrl urlGeneratorFromString:string];
    return [CSRPUrlGenerator urlGeneratorFromString:string];
}

static CSRPLegacyBeaconDriver* pr_newDriver(NSString* label) {
    struct CSRPLegacyBeaconFactoryLabels const*const s = &CSRPLegacyBeaconFactoryLabels;
    NSString* const sym = pr_labelMatched(label);
    if (sym == s->VRLiveAdBeacon    ) return [CSRPLegacyVRLiveAdBeacon new];
    if (sym == s->VRLiveVideoBeacon ) return [CSRPLegacyVRLiveVideoBeacon new];
    if (sym == s->JstAdBeacon       ) return [CSRPLegacyJstAdBeacon new];
    if (sym == s->JstLiveBeacon     ) return [CSRPLegacyJstLiveBeacon new];
    if (sym == s->JstTraceBeacon    ) return [CSRPLegacyJstTraceBeacon new];
    return nil;
}

- (CSRPLegacyBeaconDriver *)driverWithLabel:(NSString *)label {
    CSRPLegacyBeaconDriver* const driver = pr_newDriver(label);
    driver.dispatcher = self.dispatcher;
    driver.params = self.params;
    return driver;
}

@end
