//
//  CSRPDynamicNamedUrl.m
//
#import "CSRPDynamicNamedUrl.h"

@interface CSRPArc4random8String : NSObject <CSRPStringGenerator>
@end
@implementation CSRPArc4random8String
#pragma mark protocol CSRPStringGenerator
- (NSString *)string {
    NSString *randString = [NSString stringWithFormat:@"00000000%d", abs((int)arc4random())];
    return [randString substringFromIndex:[randString length] -8];
}
@end

#pragma mark -
typedef NSString* (*t_formatter)(NSString*, NSString*);
static NSString* pr_nilFormatter(NSString* format, NSString* param1) {
    return nil;
}
static NSString* pr_betterFormatter(NSString* format, NSString* param1) {
    return [NSString stringWithFormat:format, param1];
}
static NSString* pr_clangFormatter(NSString* format, NSString* param1) {
    char const*const p1 = param1.UTF8String;
    return [NSString stringWithFormat:format, p1];
}
static t_formatter pr_selectFormatter(NSString* format) {
    NSArray* atmarks = @[ @"%@", @"%1$@" ];
    for (NSString* i in atmarks)
        if ([format containsString:i])
            return pr_betterFormatter;
    return format ? pr_clangFormatter : pr_nilFormatter;
}

#pragma mark -
@interface CSRPDynamicPathname : NSObject <CSRPStringGenerator>
- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithFormat:(nullable NSString*)format
                                  param:(nullable id<CSRPStringGenerator>)param;
@property (nonatomic, nullable, readonly, copy) NSString* format;
@property (nonatomic, nullable, readonly) id<CSRPStringGenerator> paramGenerator;
@end
@implementation CSRPDynamicPathname {
    t_formatter _formatter;
}

- (instancetype)initWithFormat:(NSString *)format param:(id<CSRPStringGenerator>)param {
    self = [super init];
    if (self) {
        _formatter = pr_selectFormatter(format);
        _format = format;
        _paramGenerator = param;
    }
    return self;
}

#pragma mark protocol CSRPStringGenerator
- (NSString *)string {
    return _formatter(self.format, [self.paramGenerator string]);
}
@end

#pragma mark -
@implementation CSRPDynamicNamedUrl

- (instancetype)initWithUrl:(NSURL *)base name:(id<CSRPStringGenerator>)name {
    self = [super init];
    if (self) {
        _baseUrl = base;
        _nameGenerator = name;
    }
    return self;
}

#pragma mark protocol CSRPUrlGenerator
- (NSURL *)url {
    NSURL* const base = self.baseUrl;
    NSString* const name = [self.nameGenerator string];
    if (!name)
        return base;
    if (!base)
        return [NSURL URLWithString:name];
    return [NSURL URLWithString:name relativeToURL:base];
}

#pragma mark - factory methods

+ (id<CSRPStringGenerator>)stringGeneratorFromString:(NSString *)format {
    return [CSRPDynamicPathname.alloc initWithFormat:format
                                               param:[CSRPArc4random8String new]];
}

+ (id<CSRPUrlGenerator>)urlGeneratorFromString:(NSString *)string {
    NSString* const pathSep = @"/";
    NSRange range = [string rangeOfString:pathSep options:NSBackwardsSearch];
    if (NSNotFound == range.location)
        return [self urlGeneratorWithBaseUrl:nil format:string];
    NSUInteger const index = range.location + range.length;
    NSString* const base = [string substringToIndex:index];
    NSString* const format = [string substringFromIndex:index];
    return [self urlGeneratorWithBaseUrl:[NSURL URLWithString:base] format:format];
}

+ (id<CSRPUrlGenerator>)urlGeneratorWithBaseUrl:(NSURL *)url format:(NSString *)format {
    return [self.alloc initWithUrl:url
                              name:[self stringGeneratorFromString:format]];
}

@end
