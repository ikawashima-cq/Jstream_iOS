//
//  CSRPLegacyTrackingTimer.m
//
#import "CSRPLegacyTrackingTimer.h"
#import "CSRPSessionManager.h"
#import "CSRPLegacyBeaconDriver.h"
#import <CoreMedia/CoreMedia.h>

@interface CSRPLegacyTrackingTimer ()
@property (nonatomic) int lastSeconds;
@property (nonatomic, nullable) NSTimer* timer;
@end

@implementation CSRPLegacyTrackingTimer

- (instancetype)initWithSessionManager:(CSRPSessionManager *)session {
    self = [super init];
    if (self) {
        _session = session;
        _pollingIntervalSeconds = 5;
        _lastSeconds = -1;
    }
    return self;
}

- (void)dealloc {
    [_timer invalidate];
}
- (void)cancel {
    [_timer invalidate];
    _timer = nil;
}

- (void)schedule {
    [self scheduleWithTimeInterval:0.2];    // TBD
}
- (void)scheduleWithTimeInterval:(NSTimeInterval)interval {
    [self cancel];
    _timer = [NSTimer
              scheduledTimerWithTimeInterval:interval
              target:self selector:@selector(pr_onTimer:)
              userInfo:nil repeats:YES];
}
- (void)pr_onTimer:(NSTimer*)timer {
    [self executeTask];
}

- (void)executeTask {
    if (!self.playerLike.isPlaying)
        return;
    Float64 const exactSeconds = CMTimeGetSeconds(self.playerLike.currentTime);
    int const current = exactSeconds;
    int const last = _lastSeconds;
    if (last == current)
        return;
    _lastSeconds = current;

    int const pi = self.pollingIntervalSeconds;
    if (current / pi != last / pi)
        [self.session updateAdAvails];
    [self.session reportAtSeconds:exactSeconds];
    for (CSRPLegacyBeaconDriver* it in self.drivers) {
        [it trackWithSeconds:exactSeconds player:self.playerLike];
    }
}

#pragma mark CSRPActionTracker
- (void)trackEvent:(id<CSRPAdEventTypeEntry>)event ofAd:(id<CSRPTailorAdBasis>)ad {
    for (CSRPLegacyBeaconDriver* it in self.drivers) {
        [it trackWithEvent:event ofAd:ad player:self.playerLike];
    }
}
- (void)trackAction:(NSString *)action adId:(NSString *)adId {
    for (CSRPLegacyBeaconDriver* it in self.drivers) {
        [it trackWithAction:action adId:adId player:self.playerLike];
    }
}


@end

#pragma mark -
@implementation CSRPLegacyTrackingTimerWithAVPlayer
- (instancetype)initWithSessionManager:(CSRPSessionManager *)session {
    self = [super initWithSessionManager:session];
    if (self) {
        _playerHolder = [CSRPGenuineTrackingPlayer new];
        self.playerLike = _playerHolder;
    }
    return self;
}

@end
