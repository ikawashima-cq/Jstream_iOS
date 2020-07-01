//
//  CSRPSessionManager.h
//
#import <Foundation/Foundation.h>
#import "CSRPAdsParams.h"
#import "CSRPAdReporter.h"
#import "CSRPTailorAgent.h"

@protocol CSRPReporterFactory <NSObject>
- (nullable CSRPAdReporter*)reporterWithDictionary:(nullable NSDictionary*)dic;
@end

@interface CSRPSessionManager : NSObject

- (nullable instancetype)init;
- (nullable instancetype)initWithAgent:(nullable id<CSRPTailorAgent>)agent NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, weak) id<CSRPReporterFactory> reporterFactory;

- (void)startSessionWithUrl:(nullable NSURL*)tailorUrl
                     params:(nullable CSRPAdsParams*)params
                 onComplete:(void(^_Nullable)(NSURL*_Nullable manifest))handler;

@property (nonatomic, nullable, readonly) NSURL* trackingUrl;
@property (nonatomic, nullable, readonly, copy) NSString* currentAdId;

- (void)updateAdAvails;

- (void)reportAtSeconds:(Float64)seconds;

@end
