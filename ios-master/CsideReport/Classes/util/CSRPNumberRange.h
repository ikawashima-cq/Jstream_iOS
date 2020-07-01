//
//  CSRPNumberRange.h
//
#import <Foundation/Foundation.h>

@interface CSRPNumberRange : NSObject

@property (nonatomic, nullable, readonly) NSNumber* lower;
@property (nonatomic, nullable, readonly) NSNumber* upper;

- (nullable instancetype)init NS_UNAVAILABLE;
- (nullable instancetype)initWithLower:(nullable NSNumber*)lower
                                 upper:(nullable NSNumber*)upper NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)rangeWithLower:(nullable NSNumber*)lower
                                  upper:(nullable NSNumber*)upper;

- (nullable CSRPNumberRange*)intersectWithRange:(nullable CSRPNumberRange*)range;
- (nullable CSRPNumberRange*)intersectWithLower:(nullable NSNumber*)lower
                                          upper:(nullable NSNumber*)upper;

@end
