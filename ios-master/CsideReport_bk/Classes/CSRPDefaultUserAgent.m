//
//  CSRPDefaultUserAgent.m
//
#import "CSRPDefaultUserAgent.h"
#import <UIKit/UIKit.h>
#import <sys/utsname.h>

@implementation CSRPDefaultUserAgent

static NSString* pr_modelNameOfDevice() {
    struct utsname systemInfo;
    uname(&systemInfo);
    return [NSString stringWithCString:systemInfo.machine
                              encoding:NSUTF8StringEncoding];
}

+ (nullable NSString*)stringForUserAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *modelName = pr_modelNameOfDevice();
    
    NSMutableArray *splitedUserAgent = [[userAgent componentsSeparatedByString:@" "] mutableCopy];
    if (splitedUserAgent.count >= 2) {
        splitedUserAgent[1] = [NSString stringWithFormat:@"(%@;", modelName];
        userAgent = [splitedUserAgent componentsJoinedByString:@" "];
    }
    
    return userAgent;
}

@end
