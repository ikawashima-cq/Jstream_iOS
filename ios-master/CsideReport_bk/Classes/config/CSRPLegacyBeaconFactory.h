//
//  CSRPLegacyBeaconFactory.h
//
#import <Foundation/Foundation.h>
#import "CSRPLegacyBeaconDriver.h"

extern struct CSRPLegacyBeaconFactoryLabels {
    __unsafe_unretained NSString* _Nonnull VRLiveAdBeacon;
    __unsafe_unretained NSString* _Nonnull VRLiveVideoBeacon;
    __unsafe_unretained NSString* _Nonnull JstAdBeacon;
    __unsafe_unretained NSString* _Nonnull JstLiveBeacon;
    __unsafe_unretained NSString* _Nonnull JstTraceBeacon;
} const CSRPLegacyBeaconFactoryLabels;

@interface CSRPLegacyBeaconFactory : NSObject

+ (nullable NSArray<NSString*>*)arrayOfLabels;

@property (nonatomic, nullable) id<CSRPBeaconDispatcher> dispatcher;
@property (nonatomic, nullable) NSDictionary<NSString*, NSString*>* params;

- (nullable CSRPLegacyBeaconDriver*)driverWithLabel:(nullable NSString*)label;

+ (nullable id<CSRPUrlGenerator>)urlGeneratorFromString:(nullable NSString*)string
                                               forLabel:(nullable NSString*)label;

@end
