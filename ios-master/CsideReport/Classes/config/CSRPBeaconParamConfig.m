//
//  CSRPBeaconParamConfig.m
//
#import "CSRPBeaconParamConfig.h"
#import <UIKit/UIKit.h>     // UIDevice
#import <objc/runtime.h>

struct CSRPBeaconParamKeys const CSRPBeaconParamKeys = {
    .program    = @"program",
    .postal     = @"postal",
    .gender     = @"gender",
    .age        = @"age",
    .birthday   = @"birthday",
    .vr_tagid1  = @"vr_tagid1",
    .vr_tagid2  = @"vr_tagid2",
    .id1        = @"id1",
    .url        = @"url",
    .vr_opt1    = @"vr_opt1",
    .vr_opt2    = @"vr_opt2",
    .vr_opt3    = @"vr_opt3",
    .vr_opt4    = @"vr_opt4",
    .vr_opt5    = @"vr_opt5",
    .vr_opt6    = @"vr_opt6",
    .vr_opt7    = @"vr_opt7",
    .vr_opt8    = @"vr_opt8",
    .vr_opt10   = @"vr_opt10",
    .vr_opt15   = @"vr_opt15",
    .vr_opt16   = @"vr_opt16",
    .vr_opt17   = @"vr_opt17",
};

static NSArray<NSString*>* pr_arrayOfKeys() {
    struct CSRPBeaconParamKeys const*const s = &CSRPBeaconParamKeys;
    static NSArray<NSString*>* s_v = nil;
    if (!s_v) s_v =
        @[
          s->program,
          s->postal,
          s->gender,
          s->age,
          s->birthday,
          s->vr_tagid1,
          s->vr_tagid2,
          s->id1,
          s->url,
          s->vr_opt1,
          s->vr_opt2,
          s->vr_opt3,
          s->vr_opt4,
          s->vr_opt5,
          s->vr_opt6,
          s->vr_opt7,
          s->vr_opt8,
          s->vr_opt10,
          s->vr_opt15,
          s->vr_opt16,
          s->vr_opt17,
          ];
    return s_v;
}

static BOOL pr_keyExists(NSString* name) {
    for (NSString* i in pr_arrayOfKeys()) {
        if ([i isEqualToString:name])
            return YES;
    }
    return NO;
}

@interface CSRPBeaconParamConfig ()

@end
@implementation CSRPBeaconParamConfig {
    NSMutableDictionary<NSString*, NSString*>* _map;
}

@dynamic program;
@dynamic postal;
@dynamic gender;
@dynamic age;
@dynamic birthday;
@dynamic vr_tagid1;
@dynamic vr_tagid2;
@dynamic id1;
@dynamic url;
@dynamic vr_opt1;
@dynamic vr_opt2;
@dynamic vr_opt5;
@dynamic vr_opt6;
@dynamic vr_opt8;
@dynamic vr_opt15;

static NSString* pr_get_id1() {
    return UIDevice.currentDevice.identifierForVendor.UUIDString;
}

static void pr_initProps(CSRPPlayerConfig* master, NSMutableDictionary<NSString*, NSString*>* map) {
    struct CSRPBeaconParamKeys const*const s = &CSRPBeaconParamKeys;
    [map setValue:master.mediaId forKey:s->program];
    // readwrite: postal
    // readwrite: gender
    // readwrite: age
    // readwrite: birthday
    map[s->vr_tagid1] = @"1016";
    map[s->vr_tagid2] = @"0002";
    map[s->id1] = @"";
    //[map setValue:pr_get_id1() forKey:s->id1];
    [map setValue:master.pageUrl forKey:s->url];
    map[s->vr_opt1] = @"live-ad";
    [map setValue:master.mediaId forKey:s->vr_opt2];
    // @runtime: vr_opt3    ${adId}
    // @runtime: vr_opt4    pre|mid|post
    map[s->vr_opt5] = @"jstream";
    map[s->vr_opt6] = @"1016";
    // @runtime: vr_opt7    start|loop
    [map setValue:master.advertisingId forKey:s->vr_opt8];
    // @runtime: vr_opt10   ${gender}_${birthday}_${postal}
    map[s->vr_opt15] = @"jstream";
    // @runtime: vr_opt16   ${program datetime}
}

- (instancetype)initFromPlayerConfig:(CSRPPlayerConfig *)master {
    self = [super init];
    if (self) {
        _map = [NSMutableDictionary new];
        pr_initProps(master, _map);
    }
    return self;
}

- (NSDictionary<NSString *,NSString *> *)dictionary {
    NSMutableDictionary<NSString *,NSString *>* const map = _map.mutableCopy; {
        struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
        NSString* const value = [self.class vr_opt10_fromDictionary:map];
        [map setValue:value forKey:K->vr_opt10];
    }
    return map.copy;
}

static NSDictionary<NSString*, NSString*>* pr_setter2key() {
    static NSDictionary<NSString*, NSString*>* s_map = nil;
    if (!s_map) {
        NSMutableDictionary<NSString*, NSString*>* const map = [NSMutableDictionary new];
        for (NSString* name in pr_arrayOfKeys()) {
            NSString* const head = [name substringToIndex:1].uppercaseString;
            NSString* const tail = [name substringFromIndex:1];
            NSString* const selector = [NSString stringWithFormat:@"set%@%@:", head, tail];
            map[selector] = name;
        }
        s_map = map.copy;
    }
    return s_map;
}
static NSString* pr_getter(CSRPBeaconParamConfig* self, SEL sel) {
    NSString* const key = NSStringFromSelector(sel);
    return self->_map[key];
}
static void pr_setter(CSRPBeaconParamConfig* self, SEL sel, id value) {
    NSString* const key = pr_setter2key()[ NSStringFromSelector(sel)];
    [self->_map setValue:value forKey:key];
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSString* const selStr = NSStringFromSelector(sel);
    if (pr_keyExists(selStr)) {
        class_addMethod(self, sel, (IMP)pr_getter, "@@:");
        return YES;
    }
    if (pr_setter2key()[selStr]) {
        class_addMethod(self, sel, (IMP)pr_setter, "v@:@");
        return YES;
    }
    return NO;
}

- (CSRPAdsParams *)adsParams {
    CSRPAdsParams* const params = [CSRPAdsParams new];
    params.program = self.program;
    params.ifa = self.vr_opt8;

    NSString* postcd = self.postal;
    if (postcd.length >= 2) {
        params.postal = postcd;
        params.short_postal = [postcd substringWithRange:NSMakeRange(0, 2)];
    }

    NSString* birth = self.birthday;
    if (birth.length >= 6) {
        int birthYear = [[birth substringWithRange:NSMakeRange(0, 4)] intValue];
        int birthMonth = [[birth substringWithRange:NSMakeRange(4, 2)] intValue];
        params.age = [CSRPAdsParams ageSinceYear:birthYear month:birthMonth];
    }
    
    params.gender = self.gender;
    return params;
}

+ (NSString *)vr_opt10_fromDictionary:(NSDictionary<NSString *,NSString *> *)map {
    struct CSRPBeaconParamKeys const*const K = &CSRPBeaconParamKeys;
    NSString* const birth = map[K->birthday];
    NSString* const date = birth.length < 6 ? nil
        : [NSString stringWithFormat:@"%@-%@-%@"
            , [birth substringWithRange:NSMakeRange(0, 4)]
            , [birth substringWithRange:NSMakeRange(4, 2)]
            , @"01"
            ];
    return [NSString stringWithFormat:@"%@_%@_%@"
            , map[K->gender] ?: @""
            , date ?: @""
            , map[K->postal] ?: @""
            ];
}

@end
