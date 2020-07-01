#import <Foundation/Foundation.h>

#define WebParser   CSRPWebParser
@interface WebParser : NSObject {
    void (^_completionBlock)(long, NSData *);
    void (^_errorBlock)(NSError *);
    NSMutableData *_asyncData;
    float _timeout;
    long _statusCode;
}
- (id)SyncRequest:(NSURL *)url timeout:(float)timeout;
- (id)SyncRequest:(NSURL *)url;
- (void)ASyncRequest:(NSURL *)url completion:(void (^)(long, NSData *))completion error:(void (^)(NSError *))error;
- (void)ASyncRequest:(NSURL *)url completion:(void (^)(long, NSData *))completion error:(void (^)(NSError *))error timeout:(float)timeout userAgent:(NSString *)userAgent;

@end
