//
//  CSRPUrlGenerator.m
//
#import "CSRPUrlGenerator.h"

@interface CSRPConstantUrl : CSRPUrlGenerator
//- (nullable instancetype)initWithUrl:(nullable NSURL*)url NS_DESIGNATED_INITIALIZER;
@property (nonatomic, nullable, readonly) NSURL* url;
@end
@implementation CSRPConstantUrl
- (instancetype)initWithUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}
@end

#pragma mark -
@implementation CSRPUrlGenerator

- (NSURL *)url {
    return nil;     // stub implementation
}
- (NSURLComponents *)urlComponents {
    NSURL* const url = self.url;
    if (!url)
        return nil;
    return [NSURLComponents.alloc initWithURL:url resolvingAgainstBaseURL:YES];
}

#pragma mark - factory methods

+ (id<CSRPUrlGenerator>)urlGeneratorFromUrl:(NSURL *)url {
    return [CSRPConstantUrl.alloc initWithUrl:url];
}
+ (id<CSRPUrlGenerator>)urlGeneratorFromString:(NSString *)string {
    return [self urlGeneratorFromUrl:[NSURL URLWithString:string]];
}

@end
