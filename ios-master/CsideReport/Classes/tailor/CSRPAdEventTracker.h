//
//  CSRPAdEventTracker.h
//
#import "CSRPAdEventTypeEntry.h"
#import "CSRPBeaconDispatcher.h"

@protocol CSRPTailorAdBasis <NSObject>
- (nullable NSString*)adId;
- (nullable NSString*)vastAdId;
@end

@protocol CSRPAdEventTracker <NSObject>
- (void)trackEvent:(nonnull id<CSRPAdEventTypeEntry>)event ofAd:(nonnull id<CSRPTailorAdBasis>)ad;
@end

@protocol CSRPAdEventSink <NSObject>
- (nullable id<CSRPBeaconDispatcher>)beaconDispatcher;
- (nullable id<CSRPAdEventTracker>)actionTracker;
@end
