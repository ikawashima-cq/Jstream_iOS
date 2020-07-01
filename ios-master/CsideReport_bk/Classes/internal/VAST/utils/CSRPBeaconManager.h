//
//  BeaconManager.h
//  FoDPlayer
//
//  Created by y-akiyama on 2019/08/07.
//  Copyright © 2019 Fuji Television. All rights reserved.
//
#import <Foundation/Foundation.h>

#define BeaconManager   CSRPBeaconManager
@interface BeaconManager : NSObject {
    int _timeout;
    int _retry;
    int _retryCount;
    NSString *_userAgent;
}

- (void)sendBeacon:(NSURL *)url timeout:(int)timeout retry:(int)retry userAgent:(NSString *)userAgent;

@end
