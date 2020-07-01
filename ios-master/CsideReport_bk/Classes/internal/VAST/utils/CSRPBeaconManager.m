//
//  BeaconManager.m
//  FoDPlayer
//
//  Created by y-akiyama on 2019/08/07.
//  Copyright © 2019 Fuji Television. All rights reserved.
//

#import "CSRPBeaconManager.h"
#import "CSRPWebParser.h"

@implementation BeaconManager

- (void)sendBeacon:(NSURL *)url timeout:(int)timeout retry:(int)retry userAgent:(NSString *)userAgent
{
    _timeout = timeout;
    _retry = retry;
    _retryCount = -1;
    _userAgent = userAgent;
    
    [self requestUrl:url];
}

- (void)requestUrl:(NSURL *)beaconUrlString
{
    _retryCount++;
    
    WebParser *webparser = [WebParser alloc];
    [webparser ASyncRequest:beaconUrlString
                 completion:^(long statusCode, NSData *result) {
                     NSLog(@"beaconResponse%ld(%d/%d): %@", statusCode, _retryCount, _retry, beaconUrlString);
                     if (statusCode >= 400) {
                         if (_retryCount < _retry) {
                             [self requestUrl:beaconUrlString];
                         }
                     }
                 } error:^(NSError *error) {
                     NSLog(@"beaconFailed(%d/%d): %@", _retryCount, _retry, beaconUrlString);
                     if (_retryCount < _retry) {
                         [self requestUrl:beaconUrlString];
                     }
                 } timeout: _timeout
                  userAgent: _userAgent
     ];
}

@end
