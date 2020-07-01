//
//  CSRPTailorAgent.h
//
#import <Foundation/Foundation.h>

typedef void (^CSRPTailorAgent_onComplete)(NSData* _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error);
@protocol CSRPTailorAgent <NSObject>
- (void)startSessionWithUrl:(nonnull NSURL*)url data:(nullable NSData*)data onComplete:(nullable CSRPTailorAgent_onComplete)handler;
- (void)acquireAdAvailsWithUrl:(nonnull NSURL*)url onComplete:(nullable CSRPTailorAgent_onComplete)handler;
@end

@interface CSRPDefaultTailorAgent : NSObject<CSRPTailorAgent>

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic) NSTimeInterval timeoutInterval;
@property (nonatomic, nullable, copy) NSString* userAgent;

- (void)startTaskWithRequest:(nonnull NSURLRequest*)request onComplete:(nullable CSRPTailorAgent_onComplete)handler;
- (nullable NSMutableURLRequest*)requestWithUrl:(nonnull NSURL*)url;

@end
