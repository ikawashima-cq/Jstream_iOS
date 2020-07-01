//
//  CSRPAdEventTypeEntry.h
//
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CSRPAdEventTypeEnum) {
    CSRPAdEventType_NOTHING,

    CSRPAdEventType_impression,
    CSRPAdEventType_start,
    CSRPAdEventType_firstQuartile,
    CSRPAdEventType_midpoint,
    CSRPAdEventType_thirdQuartile,
    CSRPAdEventType_complete,

    CSRPAdEventType_BEYOND,
};

@protocol CSRPAdEventTypeEntry <NSObject>

- (nonnull NSString*)name;
- (NSInteger)number;    // CSRPAdEventTypeEnum or others

- (BOOL)is_impression;
- (BOOL)is_start;
- (BOOL)is_firstQuartile;
- (BOOL)is_midpoint;
- (BOOL)is_thirdQuartile;
- (BOOL)is_complete;

@end
