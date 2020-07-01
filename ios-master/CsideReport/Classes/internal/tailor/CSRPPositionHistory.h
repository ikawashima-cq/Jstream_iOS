//
//  CSRPPositionHistory.h
//
#import <Foundation/Foundation.h>
#import "CSRPNumberRange.h"

@class CSRPPositionHistory_LogEntry;

@interface CSRPPositionHistory : NSObject

// Enable code like: entry = positionHistory[1];
- (nullable CSRPPositionHistory_LogEntry*)objectAtIndexedSubscript:(NSUInteger)entryNum;

- (nullable NSArray<NSNumber*>*)primaryEntriesWithRange:(nullable CSRPNumberRange*)positionRange;

- (void)addEntryWithPosition:(double)position;

@end

#pragma mark - Local class
@interface CSRPPositionHistory_LogEntry : NSObject

@property (nonatomic, readonly) double position;    // position of playing media in seconds
@property (nonatomic, readonly) double createdAt;   // `elapsedTime` value for this `position`

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithPosition:(double)position NS_DESIGNATED_INITIALIZER;

/**
 * Returns seconds since boot, including time spent in sleep. 
 */
+ (double)elapsedTime;

@end
