//
//  CSRPAdReporter.h
//
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "CSRPBeaconDispatcher.h"

@protocol CSRPActionTracker <NSObject>
- (void)trackAction:(nonnull NSString*)action adId:(nullable NSString*)adId;
@end

@interface CSRPAdReporter : NSObject

- (nullable instancetype)initWithDictionary:(nullable NSDictionary*)dic NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, weak) id<CSRPBeaconDispatcher> beaconDispatcher;
@property (nonatomic, nullable, weak) id<CSRPActionTracker> actionTracker;

- (nullable NSString*)updatedAdIdFrom:(nullable NSString*)lastAdId atTime:(CMTime)time;
- (nullable NSString*)updatedAdIdFrom:(nullable NSString*)lastAdId atSeconds:(Float64)seconds;

@end
