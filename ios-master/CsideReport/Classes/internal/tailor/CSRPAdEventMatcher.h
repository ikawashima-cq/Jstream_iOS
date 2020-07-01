//
//  CSRPAdEventMatcher.h
//
#import <Foundation/Foundation.h>
#import "CSRPTailorAdNode+BuiltIn.h"

@class CSRPFiringEventItem;

@interface CSRPAdEventMatcher : NSObject

@property (nonatomic, nullable) NSDictionary* parsedJson;

- (nullable NSArray<CSRPFiringEventItem*>*)matchedEventsAtSeconds:(Float64)seconds;
- (nullable NSString*)updatedAdIdAtSeconds:(Float64)seconds
                                 eventSink:(nullable id<CSRPAdEventSink>)sink;

@end

@interface CSRPFiringEventItem : NSObject
- (nullable instancetype)initWithAd:(nonnull CSRPTailorAdNode*)ad
                              event:(nonnull id<CSRPTailorEventLike>)event;
@property (nonatomic, nonnull, readonly) CSRPTailorAdNode* ad;
@property (nonatomic, nonnull, readonly) id<CSRPTailorEventLike> event;

- (void)fireToSink:(nullable id<CSRPAdEventSink>)sink;
@end
