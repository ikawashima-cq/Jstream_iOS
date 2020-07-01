//
//  CSRPAdEventRestraining.h
//
#import <Foundation/Foundation.h>
@class CSRPAdEventTypeEntry;        //#import "CSRPAdEventTypeRegistry.h"

@protocol CSRPAdEventRestraining <NSObject>
- (BOOL)wildlyMatchesWithEvent:(nullable CSRPAdEventTypeEntry*)event;
- (nullable id<CSRPAdEventRestraining>)updatedWithEvent:(nullable CSRPAdEventTypeEntry*)event
                                                  logAt:(double)logAt;
@end

@interface CSRPAdEventStrictRestraint : NSObject <CSRPAdEventRestraining>
@property (class, nonatomic) NSTimeInterval intervalRegardedAsSame;
@end

#if 0
@interface CSRPAdEventSameAllRestraint : NSObject <CSRPAdEventRestraining>
@end
#endif
