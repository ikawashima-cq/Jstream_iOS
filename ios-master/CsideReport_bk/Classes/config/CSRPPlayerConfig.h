//
//  CSRPPlayerConfig.h
//
#import <Foundation/Foundation.h>
#import "CSRPBeaconUrlConfig.h"
#import "CSRPBeaconDispatcher.h"

@interface CSRPPlayerConfig : NSObject

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic) BOOL debugSendBeaconFlg;
@property (nonatomic) BOOL testSendBeaconFlg;
@property (nonatomic) BOOL liveFlg;
@property (nonatomic) long live_SSAI_LiveCurrent_Offset_MilliSecond;
@property (nonatomic) int SSAI_Tracking_Offset_Second_Start;
@property (nonatomic) int SSAI_Tracking_Offset_Second_End;
@property (nonatomic, nullable, copy) NSString* mediaId;
@property (nonatomic, nullable, copy) NSString* pageUrl;
@property (nonatomic, nullable, copy) NSString* advertisingId;
@property (nonatomic) int beaconTimeout;
@property (nonatomic) int beaconRetry;

- (nullable id<CSRPBeaconDispatcher>)newBeaconDispatcher;

@end
