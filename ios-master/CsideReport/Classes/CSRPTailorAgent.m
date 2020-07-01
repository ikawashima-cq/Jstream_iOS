//
//  CSRPTailorAgent.m
//
#import "CSRPTailorAgent.h"
#import "CSRPDefaultUserAgent.h"

@implementation CSRPDefaultTailorAgent

- (instancetype)init {
    self = [super init];
    if (self) {
        _timeoutInterval = 10.0;
        _userAgent = [CSRPDefaultUserAgent stringForUserAgent];
    }
    return self;
}

- (void)startSessionWithUrl:(NSURL *)url data:(NSData *)data onComplete:(CSRPTailorAgent_onComplete)handler {
    NSMutableURLRequest *request = [self requestWithUrl:url];
    [request setHTTPMethod: @"POST"];
    [request setValue: self.userAgent forHTTPHeaderField: @"User-Agent"];
    [request setValue: @"application/json" forHTTPHeaderField: @"Content-Type"];
    [request setValue: [NSString stringWithFormat:@"%@", @(data.length)] forHTTPHeaderField: @"Content-Length"];
    [request setHTTPBody: data];
    [self startTaskWithRequest:request onComplete:handler];
}

- (void)acquireAdAvailsWithUrl:(NSURL *)url onComplete:(CSRPTailorAgent_onComplete)handler {
    NSMutableURLRequest *request = [self requestWithUrl:url];
    [self startTaskWithRequest:request onComplete:handler];
}

- (void)startTaskWithRequest:(NSURLRequest *)request onComplete:(CSRPTailorAgent_onComplete)handler {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:handler];
    [task resume];
}

- (NSMutableURLRequest *)requestWithUrl:(NSURL *)url {
    return [NSMutableURLRequest
            requestWithURL: url
            cachePolicy: NSURLRequestUseProtocolCachePolicy
            timeoutInterval: self.timeoutInterval];
}

@end
