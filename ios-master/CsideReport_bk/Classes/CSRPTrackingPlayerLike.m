//
//  CSRPTrackingPlayerLike.m
//
#import "CSRPTrackingPlayerLike.h"

@implementation CSRPGenuineTrackingPlayer

- (instancetype)init {
    return self = [super init];
}
- (instancetype)initWithPlayer:(AVPlayer *)player {
    self = [super init];
    if (self) {
        _player = player;
    }
    return self;
}

- (CMTime)currentTime {
    return self.player.currentItem.currentTime;
}
- (BOOL)isPlaying {
    AVPlayer* const player = self.player;
    return player
    && !player.error
    && player.rate != 0.0;
}
- (NSDate *)currentDate {
    // maybe currentTime + #EXT-X-PROGRAM-DATE-TIME
    return self.player.currentItem.currentDate;
}

@end
