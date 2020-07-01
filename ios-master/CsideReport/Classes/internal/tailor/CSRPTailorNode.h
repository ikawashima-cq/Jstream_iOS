//
//  CSRPTailorNode.h
//
#import <Foundation/Foundation.h>
#import "CSRPNumberRange.h"
#import "CSRPAdEventTypeRegistry.h"
#import "CSRPAdEventTracker.h"
#import "CSRPFiredAdEvents.h"

@interface CSRPTailorNode : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithDictionary:(nullable NSDictionary*)dic;

@property (nonatomic, readonly, nullable) CSRPNumberRange* timeRange;
@property (nonatomic, readonly, nonnull) NSDictionary* dic;

@end

@protocol CSRPTailorEventLike <NSObject>
@property (nonatomic, readonly, nullable) CSRPNumberRange* timeRange;
@property (nonatomic, readonly, nullable) CSRPAdEventTypeEntry* eventEntry;
@end

@interface CSRPTailorEventNode : CSRPTailorNode <CSRPTailorEventLike>
- (nullable NSString*)eventType;
- (nullable NSArray<NSString*>*)beaconUrls;
@end

@interface CSRPTailorAdNode : CSRPTailorNode <CSRPTailorAdBasis>
- (nullable NSString*)adId;
- (nullable NSString*)vastAdId;
- (nullable NSArray<CSRPTailorEventNode*>*)trackingEvents;
- (nullable CSRPAdLid*)localId;
@end

@interface CSRPTailorAvailNode : CSRPTailorNode
- (nullable NSArray<CSRPTailorAdNode*>*)ads;
@end

@interface CSRPTailorRootNode : CSRPTailorNode
- (nullable NSArray<CSRPTailorAvailNode*>*)avails;
@end
