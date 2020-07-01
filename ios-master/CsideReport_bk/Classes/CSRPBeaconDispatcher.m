//
//  CSRPBeaconDispatcher.m
//
#import "CSRPBeaconDispatcher.h"

@implementation CSRPFakeBeaconDispatcher

- (void)postBeaconToUrl:(NSURL *)url {
    NSLog(@"%s: %@", __func__, url);
}

@end
