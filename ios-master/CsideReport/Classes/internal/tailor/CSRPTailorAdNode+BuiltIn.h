//
//  CSRPTailorAdNode+BuiltIn.h
//
#import <Foundation/Foundation.h>
#import "CSRPTailorNode.h"

@interface CSRPTailorAdNode () {
    NSArray<id<CSRPTailorEventLike>>* _eventLikes;
}
@end
@interface CSRPTailorAdNode (BuiltIn)
- (nullable NSArray<id<CSRPTailorEventLike>>*)eventLikes;
@end

@interface CSRPTailorBuiltInEvent : NSObject <CSRPTailorEventLike>
+ (nullable NSArray<id<CSRPTailorEventLike>>*)eventLikesWithTimeRange:(nullable CSRPNumberRange*)range;
@end
