//
//  CSRPAdReporter.m
//
#import "CSRPAdReporter.h"

@interface CSRPAdReporter () {
    NSDictionary* _dictionary;
}
@end

@implementation CSRPAdReporter

- (instancetype)init {
    return self = [self initWithDictionary:nil];
}

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    self = [super init];
    if (self) {
        _dictionary = [dic copy];
    }
    return self;
}

- (NSString *)updatedAdIdFrom:(NSString *)lastAdId atTime:(CMTime)time {
    return [self pr_updatedAdIdFrom:lastAdId atSeconds:CMTimeGetSeconds(time)];
}

- (NSString *)updatedAdIdFrom:(NSString *)lastAdId atSeconds:(Float64)seconds {
    return [self pr_updatedAdIdFrom:lastAdId atSeconds:seconds];
}

- (NSString *)pr_updatedAdIdFrom:(NSString *)lastAdId atSeconds:(int)checkTime {
#if !DEBUG
#define DB_addLog(a, b)
#else
    NSMutableArray<NSString*>* const firedLogs = NSMutableArray.new;
    void (^DB_addLog)(NSString*, NSString*) = ^(NSString* adTime, NSString* eventType) {
        [firedLogs addObject:[NSString stringWithFormat:@"(vastAdId)adStartTime-duration:%@ eventType:%@", adTime, eventType]];
    };
#endif

    NSDictionary* const _ssaiVASTDictionary = _dictionary;
    NSString* _playingAdId = lastAdId ?: @"";

    NSString *adTimeList = @"";
    int adCurrentTime = -1;
    int adDuration = -1;
    NSString *playingAdId = @"";
    int adQueuePoint = -1;
    
    if (_ssaiVASTDictionary && _ssaiVASTDictionary[@"avails"]) {
        NSArray *avails = _ssaiVASTDictionary[@"avails"];
        for (int a = 0; a < avails.count; a ++) {
            NSArray * ads = avails[a][@"ads"];
            if (ads.count > 0) {
                for (int b = 0; b < ads.count; b ++) {
                    int adStartTime = [ads[b][@"startTimeInSeconds"] intValue];
                    int adEndTime = adStartTime + [ads[b][@"durationInSeconds"] intValue];
                    NSString *addString = [NSString stringWithFormat:@"(%@)%d-%d, ", ads[b][@"vastAdId"], adStartTime, [ads[b][@"durationInSeconds"] intValue]];
                    adTimeList = [NSString stringWithFormat:@"%@%@", adTimeList, addString];
                    if (checkTime >= adStartTime && checkTime <= adEndTime) {
                        adQueuePoint = adStartTime;
                        playingAdId = ads[b][@"vastAdId"];
                        adCurrentTime = checkTime - adStartTime;
                        adDuration = [ads[b][@"durationInSeconds"] intValue];
                        NSArray *trackingEvents = ads[b][@"trackingEvents"];
                        if (trackingEvents.count > 0) {
                            for (int c = 0; c < trackingEvents.count; c ++) {
                                NSString *eventType = trackingEvents[c][@"eventType"];
                                if ([eventType isEqualToString:@"start"] || [eventType isEqualToString:@"firstQuartile"] || [eventType isEqualToString:@"midpoint"] || [eventType isEqualToString:@"thirdQuartile"] || [eventType isEqualToString:@"complete"] || [eventType isEqualToString:@"impression"]) {
                                    if (checkTime == [ads[b][@"trackingEvents"][c][@"startTimeInSeconds"] intValue]) {
                                        DB_addLog(addString, eventType);
                                        NSArray *beaconUrls = ads[b][@"trackingEvents"][c][@"beaconUrls"];
                                        for (int d = 0; d < beaconUrls.count; d ++) {
                                            if (beaconUrls[d] && ![beaconUrls[d] isEqualToString:@""]) {
                                                NSURL* url = [NSURL URLWithString:beaconUrls[d]];
                                                if (url)
                                                    [self.beaconDispatcher postBeaconToUrl:url];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        if (![_playingAdId isEqualToString: playingAdId]) {
                            _playingAdId = playingAdId ?: @"";
                            DB_addLog(addString, @"impression");
                            [self.actionTracker trackAction:@"impression" adId:playingAdId];
                        }
                        if (adCurrentTime == 0) {
                            DB_addLog(addString, @"start");
                            [self.actionTracker trackAction:@"start" adId:playingAdId];
                        }
                        if (adCurrentTime > 0 && adCurrentTime < adDuration) {
                            //
                        }
                        if (adCurrentTime == adDuration) {
                            DB_addLog(addString, @"complete");
                            [self.actionTracker trackAction:@"complete" adId:playingAdId];
                        }
                        
                    }
                }
            }
        }
    }
#if 0
    NSLog(@"SSAIManager.checkTime/adTimeList: %d/%@", checkTime, adTimeList);
    if (playingAdId && ![playingAdId isEqualToString:@""]) {
        NSLog(@"SSAIManager.adPlaying(%@): %d/%@", playingAdId, checkTime, adTimeList);
    }
#endif
#if DEBUG
    if (firedLogs.count) NSLog(@"%s: firedLogs: %@", __func__, firedLogs);
#endif
    return _playingAdId.length ? _playingAdId : nil;
}

@end
