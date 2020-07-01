//
//  CSRPDynamicNamedUrl.h
//
#import <Foundation/Foundation.h>
#import "CSRPUrlGenerator.h"

@protocol CSRPStringGenerator <NSObject>
- (nullable NSString*)string;
@end

@interface CSRPDynamicNamedUrl : CSRPUrlGenerator

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithUrl:(nullable NSURL*)base
                                name:(nullable id<CSRPStringGenerator>)name NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, readonly) NSURL* baseUrl;
@property (nonatomic, nullable, readonly) id<CSRPStringGenerator> nameGenerator;

// @return  generator with random name formatted by parameter
+ (nullable id<CSRPStringGenerator>)stringGeneratorFromString:(nullable NSString*)format;
+ (nullable id<CSRPUrlGenerator>)urlGeneratorFromString:(nullable NSString*)string;
+ (nullable id<CSRPUrlGenerator>)urlGeneratorWithBaseUrl:(nullable NSURL*)url
                                                format:(nullable NSString*)format;

@end
