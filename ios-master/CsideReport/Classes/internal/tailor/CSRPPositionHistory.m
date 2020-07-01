//
//  CSRPPositionHistory.m
//
#import "CSRPPositionHistory.h"
#import "CSRPPositionHistory_FifoCache.h"

static struct CSRPPositionHistory_Config {
    NSUInteger capacity;
    float unitableTimespan;
} const s_config = {
    .capacity = 64,
    .unitableTimespan = 3.5,
};

@implementation CSRPPositionHistory {
    CSRPPositionHistory_FifoCache<CSRPPositionHistory_LogEntry*>* _entries;
    NSArray<CSRPNumberRange*>* _nonstops;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self->_entries = [CSRPPositionHistory_FifoCache.alloc initWithCapacity:s_config.capacity];
        self->_nonstops = NSMutableArray.new;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@{{{\n  %@: %@\n  %@: %@\n}}}"
            , @"CSRPPositionHistory"
            , @"nonstops", _nonstops
            , @"entries", _entries
            ];
}

- (CSRPPositionHistory_LogEntry *)objectAtIndexedSubscript:(NSUInteger)entryNum {
    return self->_entries[entryNum];
}

typedef CSRPPositionHistory_FifoCacheReader<CSRPPositionHistory_LogEntry*>  T_Reader;
typedef NSMutableArray<CSRPNumberRange*>    T_RangeArray;

static T_RangeArray* pr_shrinkHead(T_RangeArray* nonstops, T_Reader* entries) {
    if (entries.isFull && 0 < nonstops.count) {
        CSRPNumberRange* const entryRange = nonstops[0];
        NSUInteger const lowerEntry = entryRange.lower.intValue;
        NSUInteger const upperEntry = entryRange.upper.intValue;
        NSUInteger const newHead = entries.nextFirst;
        if (lowerEntry < newHead) {
            if (upperEntry <= newHead) [nonstops removeObjectAtIndex:0];
            else nonstops[0] = [CSRPNumberRange rangeWithLower:@(newHead) upper:entryRange.upper];
        }
    }
    return nonstops;
}
static T_RangeArray* pr_extendTail(T_RangeArray* nonstops, T_Reader* entries, double position) {
    NSNumber* const newTail = @(entries.nextLast);
    CSRPPositionHistory_LogEntry* const last = entries[entries.last];
    double const lastPosition = last.position;
    if (last && lastPosition <= position && position < lastPosition + s_config.unitableTimespan) {
        nonstops[nonstops.count - 1] = [CSRPNumberRange rangeWithLower:nonstops.lastObject.lower upper:newTail];
    } else {
        CSRPNumberRange* const newRange = [CSRPNumberRange rangeWithLower:newTail upper:newTail];
        CSRPNumberRange* const lastRange = nonstops.lastObject;
        if (lastRange && NSOrderedSame == [lastRange.lower compare:lastRange.upper])
            nonstops[nonstops.count - 1] = newRange;    // shrink stand alone
        else [nonstops addObject:newRange];
    }
    return nonstops;
}

- (void)addEntryWithPosition:(double)position {
    T_RangeArray* nonstops = pr_shrinkHead(self->_nonstops.mutableCopy, self->_entries);
    nonstops = pr_extendTail(nonstops, self->_entries, position);
    [self->_entries addElement:[CSRPPositionHistory_LogEntry.alloc initWithPosition:position]];
    self->_nonstops = nonstops.copy;
}

static NSUInteger pr_binarySearch(CSRPPositionHistory* th, NSUInteger lower, NSUInteger upper, double position) {
    static NSComparator const comp = ^(id obj1, id obj2) {
        double const pos1 = [(CSRPPositionHistory_LogEntry*)obj1 position];
        double const pos2 = [(CSRPPositionHistory_LogEntry*)obj2 position];
        return  pos1 < pos2 ? NSOrderedAscending
            :   pos1 > pos2 ? NSOrderedDescending
            :   NSOrderedSame;
    };
    return [th->_entries indexOfObject:[CSRPPositionHistory_LogEntry.alloc initWithPosition:position]
                         inSortedRange:NSMakeRange(lower, 1 + upper - lower)
                       usingComparator:comp];
}

- (NSArray<NSNumber *> *)primaryEntriesWithRange:(CSRPNumberRange *)positionRange {
    CSRPPositionHistory_FifoCacheReader<CSRPPositionHistory_LogEntry*>* const entries = self->_entries;
    NSMutableArray<NSNumber*>* const result = NSMutableArray.new;
    for (CSRPNumberRange* const entryRange in self->_nonstops) {
        NSUInteger const lowerEntry = entryRange.lower.intValue;
        NSUInteger const upperEntry = entryRange.upper.intValue;
        CSRPNumberRange* const xR =
            [positionRange intersectWithLower:@(entries[lowerEntry].position)
                                        upper:@(entries[upperEntry].position)];
        double const xR_low = xR.lower.doubleValue;
        if (xR_low <= xR.upper.doubleValue) {   // is valid intersection?
            NSUInteger const found = pr_binarySearch(self, lowerEntry, upperEntry, xR_low);
            if (![entries isReducingFirst:found])
                [result addObject:@(found)];
        }
    }
    return result.copy;
}

@end

@implementation CSRPPositionHistory_LogEntry

- (instancetype)initWithPosition:(double)position {
    self = [super init];
    if (self) {
        self->_position = position;
        self->_createdAt = self.class.elapsedTime;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"LogEntry{ %@ %@ }", @(_position), @(_createdAt)];
}

+ (double)elapsedTime {
    // TODO: struct timeval .tv_sec
    // on iOS: https://stackoverflow.com/a/12490414
    // on Android: https://developer.android.com/reference/android/os/SystemClock.html#elapsedRealtime()
    return CFAbsoluteTimeGetCurrent();
}

@end
