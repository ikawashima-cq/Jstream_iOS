//
//  CSRPBeaconParamConfig.h
//
#import <Foundation/Foundation.h>
#import "CSRPPlayerConfig.h"
#import "CSRPAdsParams.h"

extern struct CSRPBeaconParamKeys {
    __unsafe_unretained NSString* _Nonnull program;
    __unsafe_unretained NSString* _Nonnull postal;
    __unsafe_unretained NSString* _Nonnull gender;
    __unsafe_unretained NSString* _Nonnull age;
    __unsafe_unretained NSString* _Nonnull birthday;
    __unsafe_unretained NSString* _Nonnull vr_tagid1;
    __unsafe_unretained NSString* _Nonnull vr_tagid2;
    __unsafe_unretained NSString* _Nonnull id1;
    __unsafe_unretained NSString* _Nonnull url;
    __unsafe_unretained NSString* _Nonnull vr_opt1;
    __unsafe_unretained NSString* _Nonnull vr_opt2;
    __unsafe_unretained NSString* _Nonnull vr_opt3;
    __unsafe_unretained NSString* _Nonnull vr_opt4;
    __unsafe_unretained NSString* _Nonnull vr_opt5;
    __unsafe_unretained NSString* _Nonnull vr_opt6;
    __unsafe_unretained NSString* _Nonnull vr_opt7;
    __unsafe_unretained NSString* _Nonnull vr_opt8;
    __unsafe_unretained NSString* _Nonnull vr_opt10;
    __unsafe_unretained NSString* _Nonnull vr_opt15;
    __unsafe_unretained NSString* _Nonnull vr_opt16;
} const CSRPBeaconParamKeys;

@interface CSRPBeaconParamConfig : NSObject

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initFromPlayerConfig:(nullable CSRPPlayerConfig*)master NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, readonly) NSString* program;
@property (nonatomic, nullable, copy) NSString* postal;
@property (nonatomic, nullable, copy) NSString* gender;
@property (nonatomic, nullable, copy) NSString* age;
@property (nonatomic, nullable, copy) NSString* birthday;
@property (nonatomic, nullable, readonly) NSString* vr_tagid1;
@property (nonatomic, nullable, readonly) NSString* vr_tagid2;
@property (nonatomic, nullable, readonly) NSString* id1;
@property (nonatomic, nullable, readonly) NSString* url;
@property (nonatomic, nullable, readonly) NSString* vr_opt1;
@property (nonatomic, nullable, readonly) NSString* vr_opt2;
@property (nonatomic, nullable, readonly) NSString* vr_opt5;
@property (nonatomic, nullable, readonly) NSString* vr_opt6;
@property (nonatomic, nullable, readonly) NSString* vr_opt8;
@property (nonatomic, nullable, readonly) NSString* vr_opt15;

- (nullable NSDictionary<NSString*, NSString*>*)dictionary;

- (nullable CSRPAdsParams*)adsParams;

+ (nullable NSString*)vr_opt10_fromDictionary:(nullable NSDictionary<NSString*, NSString*>*)dictionary;

@end
