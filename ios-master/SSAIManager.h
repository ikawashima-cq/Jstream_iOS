//
//  SSAIManager.h
//  ogtest7
//
//  Copyright © 2019 co3-mac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSRPSessionManager.h"
@protocol CSRPLegacyBeaconDriver;   //#import "CSRPLegacyBeaconDriver.h"
#import "CSRPBeaconParamConfig.h"

@interface SSAIManager : NSObject <CSRPReporterFactory, CSRPActionTracker>

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, readonly) CSRPPlayerConfig* playerConfig;
@property (nonatomic, nullable, readonly) CSRPSessionManager* sessionManager;
@property (nonatomic, nullable, weak) id<CSRPActionTracker> actionTracker;

- (nullable NSArray<id<CSRPLegacyBeaconDriver>>*)newBeaconDrivers;
- (nullable CSRPAdsParams*)newAdsParams;

- (nullable CSRPBeaconParamConfig*)acquireBeaconParamConfig;
+ (nullable CSRPPlayerConfig*)acquirePlayerConfig;

@end
