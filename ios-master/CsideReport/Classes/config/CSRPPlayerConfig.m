//
//  CSRPPlayerConfig.m
//
#import "CSRPPlayerConfig.h"
#import "CSRPDefaultBeaconDispatcher.h"
#import <AdSupport/AdSupport.h>

@implementation CSRPPlayerConfig

static NSString* pr_advertisingIdOr(NSString* optout) {
    ASIdentifierManager* const man = ASIdentifierManager.sharedManager;
    if (!man.advertisingTrackingEnabled)
        return optout;
    return man.advertisingIdentifier.UUIDString;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _debugSendBeaconFlg = false;
        _SSAI_Tracking_Offset_Second_Start = 0;
        _SSAI_Tracking_Offset_Second_End = 0;
        _advertisingId = pr_advertisingIdOr(@"optout");
        _beaconTimeout = 60;
        _beaconRetry = 4;
    }
    return self;
}

- (id<CSRPBeaconDispatcher>)newBeaconDispatcher {
    if (self.debugSendBeaconFlg)
        return [CSRPFakeBeaconDispatcher new];
    CSRPDefaultBeaconDispatcher* const d = [CSRPDefaultBeaconDispatcher new];
    d.timeout = self.beaconTimeout;
    d.retry = self.beaconRetry;
    return d;
}

@end
