//
//  CSRPSessionManager.m
//
#import "CSRPSessionManager.h"
#import "CSRPAdEventMatcher.h"

@interface CSRPSessionManager ()
@property (nonatomic, nullable, readwrite) NSURL* trackingUrl;
@property (nonatomic, nullable, readwrite, copy) NSString* currentAdId;

@property (nonatomic, nullable, readonly) id<CSRPTailorAgent> tailorAgent;
@property (nonatomic, nullable) CSRPAdReporter* reporter;
@property (nonatomic, nullable) CSRPAdEventMatcher* matcher;
@property (nonatomic, nullable) NSData* jsonData;
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
                 NSLog(@"manifestUrl: %@://%@%@", tailorUrl.scheme , tailorUrl.host , jsonDic[@"manifestUrl"]);
                 NSLog(@"trackingUrl: %@://%@%@", tailorUrl.scheme , tailorUrl.host , jsonDic[@"trackingUrl"]);
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
         if (response && !error && data)
             [self pr_onReceivedJsonData:data];
     }];
}

- (void)pr_onReceivedJsonData:(NSData*)data {
    if ([self->_jsonData isEqualToData:data])
        return;
    NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    self->_jsonData = data;
    self->_matcher = self->_matcher ?: CSRPAdEventMatcher.new;
    self->_matcher.parsedJson = dic;
    self.reporter = [self.reporterFactory reporterWithDictionary:dic];
}

- (void)reportAtSeconds:(Float64)seconds {
#if 0   // legacy version
    self.currentAdId = [self.reporter updatedAdIdFrom:self.currentAdId atSeconds:seconds];
#elif 1 // history version
    NSString* const adId = [self->_matcher updatedAdIdAtSeconds:seconds eventSink:self.reporter];
    if (adId.length)
        self.currentAdId = adId;
#else   // only for debug
    static NSString* s_lastMatcherStr = nil;
    NSString* const matcherString = [self->_matcher updatedAdIdAtSeconds:seconds eventSink:self.reporter];
    s_lastMatcherStr = matcherString ?: s_lastMatcherStr;
    self.currentAdId = [self.reporter updatedAdIdFrom:self.currentAdId atSeconds:seconds];
    NSString* const currentAdId = self.currentAdId;
    if (!currentAdId && !s_lastMatcherStr)
        return;
    if (currentAdId && s_lastMatcherStr && [currentAdId isEqualToString:s_lastMatcherStr])
        return;
    NSLog(@"%s: %@ vs. %@", __func__, s_lastMatcherStr, self.currentAdId);
#endif
}

@end
