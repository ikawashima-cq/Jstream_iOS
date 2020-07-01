//
//  CSRPAdsParams.m
//
#import "CSRPAdsParams.h"

/*
@interface CSRPAdsParams ()
@property (nonatomic, nullable, copy, readonly) NSString* device;
@property (nonatomic, nullable, copy, readonly) NSString* bundle;
@property (nonatomic, nullable, copy, readonly) NSString* domain;
@end
*/

@implementation CSRPAdsParams

- (instancetype)init {
    self = [super init];
    if (self) {
        _device = @"0002";  // 2: iOS
        _bundle = [[NSBundle mainBundle] bundleIdentifier];
        _domain = @"tver";
    }
    return self;
}

- (NSString *)stringAsJson {
    NSString *device = self.device ?: @"";
    NSString *mediaId = self.program ?: @"";
    NSString *postCode = self.postal ?: @"";
    NSString *postCodeShort = self.short_postal ?: @"";
    NSString *gender = self.gender ?: @"";
    NSString *domain = self.domain ?: @"";
    int age = (int)self.age;
    NSString *ifa = self.ifa ?: @"";
    NSString *bundleID = self.bundle ?: @"";
    NSString *appName = self.name ?: @"";
    return [NSString stringWithFormat:@"{\"adsParams\":{\"device\":\"%@\",\"program\":\"%@\",\"postal\":\"%@\",\"short_postal\":\"%@\",\"gender\":\"%@\",\"age\": \"%d\",\"site_domain\":\"%@\",\"ifa\":\"%@\",\"bundle\":\"%@\",\"domain\":\"%@\",\"name\":\"%@\"}}", device, mediaId, postCode, postCodeShort, gender, age, domain, ifa, bundleID, domain, appName];
}

+ (NSInteger)ageSinceYear:(int)year month:(int)month {
    int birthYear = year;
    int birthMonth = month;
    
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    int currentYear = [[formatter stringFromDate:currentDate] intValue];
    [formatter setDateFormat:@"MM"];
    int currentMonth = [[formatter stringFromDate:currentDate] intValue];
    
    int age = currentYear - birthYear;
    if (currentMonth < birthMonth) {
        age = age - 1;
    }
    return age;
}

@end
