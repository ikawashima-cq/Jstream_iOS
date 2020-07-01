//
//  SSAIManager.m
//  ogtest7
//
//  Copyright © 2019 co3-mac. All rights reserved.
//

#import "SSAIManager.h"
#import "CSRPBeaconUrlConfig.h"
#import "CSRPLegacyBeaconFactory.h"
#import <AdSupport/AdSupport.h>

@interface SSAIManager () {
    CSRPBeaconUrlConfig* _beaconUrlConfig;
    CSRPBeaconParamConfig* _beaconParamConfig;
    id<CSRPBeaconDispatcher> _beaconDispatcher;
    id<CSRPBeaconDispatcher> _reporterDispatcher;
    
}
@end

@implementation SSAIManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _playerConfig = [self.class acquirePlayerConfig];
        _beaconUrlConfig = [CSRPBeaconUrlConfig new];
        _sessionManager = [CSRPSessionManager.alloc initWithAgent:[CSRPDefaultTailorAgent new]];
        _sessionManager.reporterFactory = self;
        _actionTracker = self;
    }
    return self;
}

- (CSRPBeaconParamConfig *)beaconParamConfig {
    return _beaconParamConfig = _beaconParamConfig ?: [self acquireBeaconParamConfig];
}
- (id<CSRPBeaconDispatcher>)beaconDispatcher {
    return _beaconDispatcher = _beaconDispatcher ?: [self.playerConfig newBeaconDispatcher];
}
- (id<CSRPBeaconDispatcher>)reporterDispatcher {
    return _reporterDispatcher = _reporterDispatcher ?:
    [_beaconUrlConfig ssaiDispatcher:self.beaconDispatcher
                   testSendBeaconFlg:_playerConfig.testSendBeaconFlg];
}

- (NSArray<id<CSRPLegacyBeaconDriver>> *)newBeaconDrivers {
    CSRPLegacyBeaconFactory* const factory = [CSRPLegacyBeaconFactory new];
    factory.dispatcher = self.beaconDispatcher;
    factory.params = self.beaconParamConfig.dictionary;
    CSRPBeaconUrlSet* const set = [_beaconUrlConfig urlSetFromPlayerConfig:self.playerConfig];
    return [set driversFromFactory:factory];
}

#pragma mark protocol CSRPReporterFactory
- (CSRPAdReporter *)reporterWithDictionary:(NSDictionary *)dic {
    CSRPAdReporter* reporter = [CSRPAdReporter.alloc initWithDictionary:dic];
    reporter.beaconDispatcher = self.reporterDispatcher;
    reporter.actionTracker = self.actionTracker;
    return reporter;
}

#pragma mark protocol CSRPActionTracker
- (void)trackAction:(NSString *)action adId:(NSString *)adId {
    NSLog(@"%s: action: %@, adId: %@", __func__, action, adId);
}

#pragma mark -

- (CSRPAdsParams *)newAdsParams {
    CSRPAdsParams* const par = [self.beaconParamConfig adsParams];
    par.name = @"CSRPTestIOS";
    return par;
}

- (CSRPBeaconParamConfig *)acquireBeaconParamConfig {
    CSRPBeaconParamConfig* const con = [CSRPBeaconParamConfig.alloc initFromPlayerConfig:self.playerConfig];
    con.postal = @"1050014";    // TODO
    con.gender = @"m";          // TODO
    con.age = @"22";             // TODO
    con.birthday = @"199705";  // TODO
    return con;
}

static NSString* pr_advertisingIdOr(NSString* optout) {
    ASIdentifierManager* const man = ASIdentifierManager.sharedManager;
    if (!man.advertisingTrackingEnabled)
        return optout;
    return man.advertisingIdentifier.UUIDString;
}

+ (CSRPPlayerConfig *)acquirePlayerConfig {
    CSRPPlayerConfig* const con = [CSRPPlayerConfig new];
#if DEBUG && 1 // && 0
    //con.debugSendBeaconFlg = YES;
    //con.testSendBeaconFlg = YES;
#endif
    con.mediaId = @"8133810001";
    con.pageUrl = @"tver.jp";
    con.advertisingId = pr_advertisingIdOr(@"optout");
    return con;
}

- (void)trackEvent:(nonnull id<CSRPAdEventTypeEntry>)event ofAd:(nonnull id<CSRPTailorAdBasis>)ad {

}

@end
