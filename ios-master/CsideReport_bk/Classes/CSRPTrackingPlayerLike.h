//
//  CSRPTrackingPlayerLike.h
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CSRPTrackingPlayerLike <NSObject>
- (CMTime)currentTime;
- (BOOL)isPlaying;
- (nullable NSDate*)currentDate;
@end

@interface CSRPGenuineTrackingPlayer : NSObject <CSRPTrackingPlayerLike>

- (nullable instancetype)init NS_DESIGNATED_INITIALIZER;
- (nullable instancetype)initWithPlayer:(nullable AVPlayer*)player NS_DESIGNATED_INITIALIZER;

@property (nonatomic, nullable, weak) AVPlayer* player;
@end
