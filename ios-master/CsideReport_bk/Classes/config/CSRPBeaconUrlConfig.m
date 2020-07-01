//
//  CSRPBeaconUrlConfig.m
//
#import "CSRPBeaconUrlConfig.h"
#import "CSRPPlayerConfig.h"

@interface CSRPBeaconHoleDispatcher : NSObject <CSRPBeaconDispatcher>
+ (nullable id<CSRPBeaconDispatcher>) dispatcher:(nullable id<CSRPBeaconDispatcher>)dispatcher
                                         holeUrl:(nullable NSURL*)url;
@end
@implementation CSRPBeaconHoleDispatcher {
    id<CSRPBeaconDispatcher> _delegate;
    NSURL* _holeUrl;
}
- (void)postBeaconToUrl:(NSURL *)url {
    [_delegate postBeaconToUrl:_holeUrl];
}
+ (id<CSRPBeaconDispatcher>)dispatcher:(id<CSRPBeaconDispatcher>)dispatcher holeUrl:(NSURL *)url {
    if (!url || !dispatcher)
        return nil;
    CSRPBeaconHoleDispatcher* const that = [CSRPBeaconHoleDispatcher new];
    that->_delegate = dispatcher;
    that->_holeUrl = url;
    return that;
}
@end

#pragma mark -
@implementation CSRPBeaconUrlConfig

- (instancetype)init {
    self = [super init];
    if (self) {
        //        _beacon_vr_live_video = @"https://test01.co3.co.jp/CollectLog/beacontest.html?%1$sbeacontype=vr_video";
        //        _beacon_vr_live_video = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/beacon/play.html?%1$sbeacontype=vr_video";
                _beacon_vr_live_video = @"https://log11.interactive-circle.jp/data11/%1$s.gif";
                _beacon_vr_live_video_test = @"https://log11stg.interactive-circle.jp/data11/%1$s.gif";
        //        _beacon_vr_live_video_test = @"https://log11stg.interactive-circle.jp/data11/$@.gif";
        //        _beacon_vr_live_ad = @"https://test01.co3.co.jp/CollectLog/beacontest.html?%1$sbeacontype=vr_ad";
        //        _beacon_vr_live_ad = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/beacon/play.html?%1$sbeacontype=vr_ad";
                _beacon_vr_live_ad = @"https://log10.interactive-circle.jp/data10/%1$s.gif";
                _beacon_vr_live_ad_test = @"https://log10stg.interactive-circle.jp/data10/%1$s.gif";
        //        _beacon_jst_video = @"https://test01.co3.co.jp/CollectLog/beacontest.html?beacontype=jst_video";
                _beacon_jst_video = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/beacon/play.html?beacontype=jst_video";
        //        _beacon_jst_video = @"https://fod.fujitv.co.jp/mz/view_log.aspx";
        //        _beacon_jst_video_test
        //        _beacon_jst_ad = @"https://test01.co3.co.jp/CollectLog/beacontest.html?beacontype=jst_ad";
                _beacon_jst_ad = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/beacon/play.html?beacontype=jst_ad";
        //      _beacon_jst_ad = @"https://fod.fujitv.co.jp/ad/al.aspx";
        //        _beacon_jst_ad_test
        //        _beacon_jst_trace = @"https://test01.co3.co.jp/CollectLog/beacontest.html?beacontype=jst_trace";
                _beacon_jst_trace = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/";
        //        _beacon_jst_trace_test
                _beacon_jst_ssai_test = @"https://e9efbdc0b7387d08b8183210c656d7a4.cdnext.stream.ne.jp/beacon/play.html?beacontype=ssai_test";
    }
    return self;
}

- (CSRPBeaconUrlSet *)urlSetForProduction {
    CSRPBeaconUrlSet* const set = [CSRPBeaconUrlSet new];
    set.vr_live_video = self.beacon_vr_live_video;
    set.vr_live_ad = self.beacon_vr_live_ad;
    set.jst_video = self.beacon_jst_video;
    set.jst_ad = self.beacon_jst_ad;
    set.jst_trace = self.beacon_jst_trace;
    return set;
}

- (CSRPBeaconUrlSet *)urlSetForTest {
    CSRPBeaconUrlSet* const set = [CSRPBeaconUrlSet new];
    set.vr_live_video = self.beacon_vr_live_video_test;
    set.vr_live_ad = self.beacon_vr_live_ad_test;
    set.jst_video = self.beacon_jst_video_test;
    set.jst_ad = self.beacon_jst_ad_test;
    set.jst_trace = self.beacon_jst_trace_test;
    return set;
}

- (CSRPBeaconUrlSet *)urlSetFromPlayerConfig:(CSRPPlayerConfig *)config {
    return config.testSendBeaconFlg
    ? [self urlSetForTest]
    : [self urlSetForProduction];
}

- (id<CSRPBeaconDispatcher>)ssaiDispatcher:(id<CSRPBeaconDispatcher>)dispatcher testSendBeaconFlg:(BOOL)isTest {
    if (!isTest)
        return dispatcher;
    NSString* str = self.beacon_jst_ssai_test;
    if (!str)
        return nil;
    return [CSRPBeaconHoleDispatcher dispatcher:dispatcher holeUrl:[NSURL URLWithString:str]];
}
@end
