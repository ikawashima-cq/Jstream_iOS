#import "CSRPWebParser.h"

@implementation WebParser

//同期処理
- (id)SyncRequest:(NSURL *)url
{
    return [self SyncRequest:url timeout:60.0];
}
- (id)SyncRequest:(NSURL *)url timeout:(float)timeout
{
    _timeout = timeout;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                         timeoutInterval:_timeout];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (!error) {
        return data;
    } else {
        return error;
    }
}

//非同期処理
- (void)ASyncRequest:(NSURL *)url completion:(void (^)(long, NSData *))completion error:(void (^)(NSError *))error
{
    [self ASyncRequest:url completion:completion error:error timeout:60.0 userAgent:nil];
}
- (void)ASyncRequest:(NSURL *)url completion:(void (^)(long, NSData *))completion error:(void (^)(NSError *))error timeout:(float)timeout userAgent:(NSString *)userAgent
{
    _completionBlock = completion;
    _errorBlock = error;
    _timeout = timeout;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                                       timeoutInterval:_timeout];
    if (userAgent != nil) {
        [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    }
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection == nil) {
    }
}

//処理開始
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _asyncData = [[NSMutableData alloc] init];
    _statusCode = ((NSHTTPURLResponse *)response).statusCode;
}

//データ受信中
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_asyncData appendData:data];
}

//エラー処理
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    _errorBlock(error);
}

//完了処理
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    _completionBlock(_statusCode, [NSData dataWithData:_asyncData]);
}

@end
