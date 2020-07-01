//
//  CSRPDefaultBeaconDispatcher.m
//
#import "CSRPDefaultBeaconDispatcher.h"
#import "CSRPDefaultUserAgent.h"
#import "internal/VAST/utils/CSRPBeaconManager.h"

@implementation CSRPDefaultBeaconDispatcher

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeout = 60;  // TBD
        _retry = 4;
        _userAgent = CSRPDefaultUserAgent.stringForUserAgent;
    }
    return self;
}

- (void)postBeaconToUrl:(NSURL *)url {
    [CSRPBeaconManager.new sendBeacon:url timeout:self.timeout retry:self.retry userAgent:self.userAgent];
}

@end
