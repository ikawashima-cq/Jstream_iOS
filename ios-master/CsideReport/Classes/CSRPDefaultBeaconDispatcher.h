//
//  CSRPDefaultBeaconDispatcher.h
//
#import "CSRPBeaconDispatcher.h"

@interface CSRPDefaultBeaconDispatcher : NSObject <CSRPBeaconDispatcher>

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic) float timeout;    // seconds
@property (nonatomic) int retry;
@property (nonatomic, nullable, copy) NSString* userAgent;

@end
