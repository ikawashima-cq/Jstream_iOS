//
//  CSRPNumberRange.m
//
#import "CSRPNumberRange.h"

@implementation CSRPNumberRange

- (instancetype)initWithLower:(NSNumber *)lower upper:(NSNumber *)upper {
    self = [super init];
    if (self) {
        self->_lower = lower;
        self->_upper = upper;
    }
    return self;
}

+ (instancetype)rangeWithLower:(NSNumber *)lower upper:(NSNumber *)upper {
    return [self.alloc initWithLower:lower upper:upper];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@[ %@ %@ ]", @"CSRPNumberRange", _lower, _upper];
}

- (CSRPNumberRange *)intersectWithRange:(CSRPNumberRange *)range {
    if (!range)
        return range;
    NSComparisonResult const cmpLow = [range.lower compare:self->_lower];
    NSComparisonResult const cmpUpp = [range.upper compare:self->_upper];
    if (cmpLow <= NSOrderedSame && NSOrderedSame <= cmpUpp)
        return self;    // range includes self
    if (cmpUpp <= NSOrderedSame && NSOrderedSame <= cmpLow)
        return range;   // self includes range
    return [self.class rangeWithLower: cmpLow <= NSOrderedSame ? self->_lower : range.lower
                                upper: NSOrderedSame <= cmpUpp ? self->_upper : range.upper];
}

- (CSRPNumberRange *)intersectWithLower:(NSNumber *)lower upper:(NSNumber *)upper {
    NSComparisonResult const cmpLow = [lower compare:self->_lower];
    NSComparisonResult const cmpUpp = [upper compare:self->_upper];
    if (cmpLow <= NSOrderedSame && NSOrderedSame <= cmpUpp)
        return self;    // [lower, upper] includes self
    return [self.class rangeWithLower: cmpLow <= NSOrderedSame ? self->_lower : lower
                                upper: NSOrderedSame <= cmpUpp ? self->_upper : upper];
}

@end
