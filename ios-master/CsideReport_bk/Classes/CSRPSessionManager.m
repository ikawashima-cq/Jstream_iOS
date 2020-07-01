//
//  CSRPSessionManager.m
//
#import "CSRPSessionManager.h"

@interface CSRPSessionManager ()
@property (nonatomic, nullable, readwrite) NSURL* trackingUrl;
@property (nonatomic, nullable, readwrite, copy) NSString* currentAdId;

@property (nonatomic, nullable, readonly) id<CSRPTailorAgent> tailorAgent;
@property (nonatomic, nullable) CSRPAdReporter* reporter;
@end

@implementation CSRPSessionManager

- (instancetype)init {
    return self = [self initWithAgent:nil];
}
- (instancetype)initWithAgent:(id<CSRPTailorAgent>)agent {
    self = [super init];
    if (self) {
        _tailorAgent = agent ?: [CSRPDefaultTailorAgent new];
    }
    return self;
}

- (void)startSessionWithUrl:(NSURL *)tailorUrl params:(CSRPAdsParams *)params onComplete:(void (^)(NSURL * _Nullable))handler {
    [self.tailorAgent
     startSessionWithUrl:tailorUrl
     data:[params.stringAsJson dataUsingEncoding:NSUTF8StringEncoding]
     onComplete:^(NSData* data, NSURLResponse* response, NSError* error) {
         NSURL *manifestUrl = nil;
         if (response && !error) {
             NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             if (jsonDic[@"manifestUrl"] && jsonDic[@"trackingUrl"]) {
                 manifestUrl = [NSURL URLWithString:jsonDic[@"manifestUrl"] relativeToURL:tailorUrl];
                 self.trackingUrl = [NSURL URLWithString:jsonDic[@"trackingUrl"] relativeToURL:tailorUrl];
             }
         }
         if (handler)
             handler(manifestUrl);
     }];
}

- (void)updateAdAvails {
    if (!self.trackingUrl)
        return;
    [self.tailorAgent
     acquireAdAvailsWithUrl:self.trackingUrl
     onComplete:^(NSData* data, NSURLResponse* response, NSError* error) {
         if (response && !error) {
             NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
             self.reporter = [self.reporterFactory reporterWithDictionary:dic];
         }
     }];
}

- (void)reportAtTime:(CMTime)time {
    self.currentAdId = [self.reporter updatedAdIdFrom:self.currentAdId atTime:time];
}
- (void)reportAtSeconds:(Float64)seconds {
    self.currentAdId = [self.reporter updatedAdIdFrom:self.currentAdId atSeconds:seconds];
}

@end
