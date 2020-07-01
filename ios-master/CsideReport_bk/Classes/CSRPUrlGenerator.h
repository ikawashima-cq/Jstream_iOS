//
//  CSRPUrlGenerator.h
//
#import <Foundation/Foundation.h>

@protocol CSRPUrlGenerator <NSObject>
- (nullable NSURL*)url;
- (nullable NSURLComponents*)urlComponents;
@end

@interface CSRPUrlGenerator : NSObject <CSRPUrlGenerator>

// @return  generator with constant URL
+ (nullable id<CSRPUrlGenerator>)urlGeneratorFromUrl:(nullable NSURL*)url;
+ (nullable id<CSRPUrlGenerator>)urlGeneratorFromString:(nullable NSString*)string;

@end
