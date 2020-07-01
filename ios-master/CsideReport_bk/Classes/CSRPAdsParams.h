//
//  CSRPAdsParams.h
//
#import <Foundation/Foundation.h>

@interface CSRPAdsParams : NSObject

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, copy) NSString* program;
@property (nonatomic, nullable, copy) NSString* postal;
@property (nonatomic, nullable, copy) NSString* short_postal;
@property (nonatomic, nullable, copy) NSString* gender;
@property (nonatomic) NSInteger age;
@property (nonatomic, nullable, copy) NSString* ifa;
@property (nonatomic, nullable, copy) NSString* name;

- (nonnull NSString*)stringAsJson;

+ (NSInteger)ageSinceYear:(int)year month:(int)month;

@end
