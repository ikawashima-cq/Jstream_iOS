//
//  CSRPBeaconDispatcher.h
//
#import <Foundation/Foundation.h>

@protocol CSRPBeaconDispatcher <NSObject>
- (void)postBeaconToUrl:(nonnull NSURL*)url;
@end

@interface CSRPFakeBeaconDispatcher : NSObject <CSRPBeaconDispatcher>
@end
