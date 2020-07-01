//
//  CSRPBeaconUrlSet.h
//
#import <Foundation/Foundation.h>
#import "CSRPLegacyBeaconFactory.h"

@interface CSRPBeaconUrlSet : NSObject

@property (nonatomic, nullable, copy) NSString* vr_live_video;
@property (nonatomic, nullable, copy) NSString* vr_live_ad;
@property (nonatomic, nullable, copy) NSString* jst_video;
@property (nonatomic, nullable, copy) NSString* jst_ad;
@property (nonatomic, nullable, copy) NSString* jst_trace;

- (nullable NSDictionary<NSString*, NSString*>*)dictionaryForFactory;
- (nullable NSArray<id<CSRPLegacyBeaconDriver>>*)driversFromFactory:(nullable CSRPLegacyBeaconFactory*)factory;

@end
