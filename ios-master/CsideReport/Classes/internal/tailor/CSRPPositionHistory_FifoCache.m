//
//  CSRPPositionHistory_FifoCache.m
//
#import "CSRPPositionHistory_FifoCache.h"

@implementation CSRPPositionHistory_FifoCacheReader
// Fake implementation.
// Objective-C does not support Generic protocol.
- (NSUInteger)first { return 1; }
- (NSUInteger)last { return 0; }
- (BOOL)isEmpty { return YES; }
- (BOOL)isFull { return NO; }
- (BOOL)isReducingFirst:(NSUInteger)first { return NO; }
- (id)objectAtIndexedSubscript:(NSUInteger)entryNum { return nil; }
- (NSUInteger)nextFirst { return 1; }
- (NSUInteger)nextLast { return 1; }
@end

@interface CSRPPositionHistory_FifoCache ()
@property (nonatomic, readonly) NSUInteger capacity;
@property (nonatomic, readonly) NSUInteger first;
@property (nonatomic, readonly) NSUInteger last;
@property (nonatomic, readonly, nonnull) NSMutableArray* ring;  // ring buffer
@end
@implementation CSRPPositionHistory_FifoCache

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self) {
        self->_capacity = capacity = capacity ?: 1;
        self->_first = 1;
        self->_last = 1 - 1;
        self->_ring = ^{
            id const value = NSNull.null;
            NSMutableArray* const ar = [NSMutableArray.alloc initWithCapacity:capacity];
            for (NSUInteger remain = capacity; remain; --remain)
                [ar addObject:value];
            return ar;
        }();    // array filled with null
    }
    return self;
}

- (BOOL)isEmpty {
    return self->_last < 1;
}
- (BOOL)isFull {
    return self->_capacity <= self->_last;
}
- (BOOL)isReducingFirst:(NSUInteger)first {
    return 1 < first && first == self->_first;
}

- (id)objectAtIndexedSubscript:(NSUInteger)entryNum {
    if (entryNum < self->_first || self->_last < entryNum)
        return nil;
    return self->_ring[entryNum % self->_capacity];
}

- (void)addElement:(id)newElement {
    if (!newElement)
        return;
    self->_first = self.nextFirst;
    NSUInteger const last = 1 + self->_last;
    self->_ring[last % self->_capacity] = newElement;
    self->_last = last;
}
- (NSUInteger)nextLast {
    return 1 + self->_last;
}
- (NSUInteger)nextFirst {
    NSUInteger const last = 1 + self->_last;
    if (self->_capacity < 1 + last)
        return 1 + last - self->_capacity;
    return self->_first;
}

- (NSString *)description {
    id props = @{
        @"capacity": @(_capacity),
        @"first": @(_first),
        @"last": @(_last),
    };
    return [NSString stringWithFormat:@"%@{{\n %@\n %@: %@\n}}"
            , @"FifoCache", props
            , @"ring", _ring
            ];
}

@end

@implementation CSRPPositionHistory_FifoCache (bsearch)
- (NSUInteger)indexOfObject:(id)object inSortedRange:(NSRange)range usingComparator:(NSComparator)cmp {
    NSBinarySearchingOptions const options = NSBinarySearchingInsertionIndex | NSBinarySearchingFirstEqual;
    NSUInteger (^binSearch)(NSUInteger, NSUInteger) = ^(NSUInteger low, NSUInteger upp) {
        return [self->_ring indexOfObject:object
                     inSortedRange:NSMakeRange(low, 1 + upp - low)
                           options:options
                   usingComparator:cmp];
    };
    NSUInteger const rangeUpp = range.location + range.length - 1;
    NSUInteger const upper = self->_last < rangeUpp ? self->_last : rangeUpp;
    NSUInteger const lower = self->_first < range.location ? range.location : self->_first;
    if (!object || upper < lower)
        return 0;  // entry#0 points nil
    NSUInteger const ixLow = lower % self->_capacity;
    NSUInteger const ixUpp = upper % self->_capacity;
    if (ixLow <= ixUpp)
        return binSearch(ixLow, ixUpp) + lower - ixLow;
    switch(cmp(object, self->_ring[0])) {
        case NSOrderedAscending:
            return binSearch(ixLow, self->_capacity - 1) + lower - ixLow;
        case NSOrderedDescending:
            return binSearch(0, ixUpp) + upper - ixUpp;
        case NSOrderedSame: // fall through
        default: return upper - ixUpp;
    }
}
@end
