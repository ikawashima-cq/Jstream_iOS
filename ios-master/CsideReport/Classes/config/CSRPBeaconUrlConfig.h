//
//  CSRPBeaconUrlConfig.h
//
#import <Foundation/Foundation.h>
#import "CSRPBeaconDispatcher.h"
#import "CSRPBeaconUrlSet.h"
@class CSRPPlayerConfig;    //#import "CSRPPlayerConfig.h"

@interface CSRPBeaconUrlConfig : NSObject

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, copy) NSString* beacon_vr_live_video;
@property (nonatomic, nullable, copy) NSString* beacon_vr_live_video_test;
@property (nonatomic, nullable, copy) NSString* beacon_vr_live_ad;
@property (nonatomic, nullable, copy) NSString* beacon_vr_live_ad_test;
@property (nonatomic, nullable, copy) NSString* beacon_jst_video;
@property (nonatomic, nullable, copy) NSString* beacon_jst_video_test;
@property (nonatomic, nullable, copy) NSString* beacon_jst_ad;
@property (nonatomic, nullable, copy) NSString* beacon_jst_ad_test;
@property (nonatomic, nullable, copy) NSString* beacon_jst_trace;
@property (nonatomic, nullable, copy) NSString* beacon_jst_trace_test;
@property (nonatomic, nullable, copy) NSString* beacon_jst_ssai_test;

- (nullable CSRPBeaconUrlSet*)urlSetForProduction;
- (nullable CSRPBeaconUrlSet*)urlSetForTest;
- (nullable CSRPBeaconUrlSet*)urlSetFromPlayerConfig:(nullable CSRPPlayerConfig*)config;

- (nullable id<CSRPBeaconDispatcher>)ssaiDispatcher:(nullable id<CSRPBeaconDispatcher>)dispatcher
                                  testSendBeaconFlg:(BOOL)isTest;

@end
