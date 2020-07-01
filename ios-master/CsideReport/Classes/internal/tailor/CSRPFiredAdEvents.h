//
//  CSRPFiredAdEvents.h
//
#import <Foundation/Foundation.h>
#import "CSRPAdEventRestraining.h"

typedef NSNumber    CSRPAdLid;  // ad local id

@interface CSRPFiredAdEvents : NSObject <CSRPAdEventRestraining>

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithAdLid:(nullable CSRPAdLid*)adLid;

@property (nonatomic, readonly, nullable) CSRPAdLid* adLid;
@property (nonatomic, readonly) NSTimeInterval updatedAt;
@property (nonatomic, readonly, nullable) id<CSRPAdEventRestraining> eventLogs;
@property (nonatomic, readonly, class, nullable) Class eventLogsClass;

@end
