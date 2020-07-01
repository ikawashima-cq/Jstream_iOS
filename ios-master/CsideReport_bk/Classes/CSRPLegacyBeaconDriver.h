//
//  CSRPLegacyBeaconDriver.h
//
#import <Foundation/Foundation.h>
#import "CSRPTrackingPlayerLike.h"
#import "CSRPBeaconDispatcher.h"
#import "CSRPUrlGenerator.h"

@protocol CSRPLegacyBeaconDriver <NSObject>
- (void)trackWithSeconds:(Float64)seconds
                  player:(nullable id<CSRPTrackingPlayerLike>)player;
- (void)trackWithAction:(nullable NSString*)action
                   adId:(nullable NSString*)adId
                 player:(nullable id<CSRPTrackingPlayerLike>)player;
@end

@interface CSRPLegacyBeaconDriver : NSObject <CSRPLegacyBeaconDriver>

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable) id<CSRPUrlGenerator> urlGenerator;
@property (nonatomic, nullable) id<CSRPBeaconDispatcher> dispatcher;
@property (nonatomic, nullable, copy) NSDictionary<NSString*, NSString*>* params;

- (nonnull NSDictionary<NSString*, NSString*>*)mergedDictionaryWithParams:
 (nullable NSDictionary<NSString*, NSString*>*)params;

- (void)dispatchWithAdditionalParams:(nullable NSDictionary<NSString*, NSString*>*)params;

@end
