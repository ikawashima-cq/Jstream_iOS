//
//  CSRPPositionHistory_FifoCache.h
//
#import <Foundation/Foundation.h>

@interface CSRPPositionHistory_FifoCacheReader<__covariant T> : NSObject

- (NSUInteger)first;
- (NSUInteger)last;
- (BOOL)isEmpty;
- (BOOL)isFull;
- (BOOL)isReducingFirst:(NSUInteger)first;

- (nullable T)objectAtIndexedSubscript:(NSUInteger)entryNum;

- (NSUInteger)nextFirst;
- (NSUInteger)nextLast;

@end

@interface CSRPPositionHistory_FifoCache<__covariant T> : CSRPPositionHistory_FifoCacheReader

- (nullable instancetype)initWithCapacity:(NSUInteger)capacity;

- (void)addElement:(nullable T)newElement;

@end

@interface CSRPPositionHistory_FifoCache<__covariant T> (bsearch)
- (NSUInteger)indexOfObject:(nonnull T)object
              inSortedRange:(NSRange)range
            usingComparator:(nonnull NSComparator)cmp;
@end
