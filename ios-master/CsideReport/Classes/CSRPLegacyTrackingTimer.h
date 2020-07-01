//
//  CSRPLegacyTrackingTimer.h
//
#import <Foundation/Foundation.h>
#import "CSRPTrackingPlayerLike.h"
#import "CSRPAdReporter.h"
@class CSRPSessionManager;          //#import "CSRPSessionManager.h"
@protocol CSRPLegacyBeaconDriver;   //#import "CSRPLegacyBeaconDriver.h"

@interface CSRPLegacyTrackingTimer : NSObject <CSRPActionTracker>

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithSessionManager:(nullable CSRPSessionManager*)session NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, weak, readonly) CSRPSessionManager* session;
@property (nonatomic, nullable, weak) id<CSRPTrackingPlayerLike> playerLike;
@property (nonatomic) int pollingIntervalSeconds;
@property (nonatomic, nullable, copy) NSArray<id<CSRPLegacyBeaconDriver>>* drivers;

- (void)cancel;
- (void)schedule;
- (void)scheduleWithTimeInterval:(NSTimeInterval)interval;

- (void)executeTask;

@end

@interface CSRPLegacyTrackingTimerWithAVPlayer : CSRPLegacyTrackingTimer

- (nullable instancetype)initWithSessionManager:(nullable CSRPSessionManager*)session NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nonnull, readonly) CSRPGenuineTrackingPlayer* playerHolder;

@end
