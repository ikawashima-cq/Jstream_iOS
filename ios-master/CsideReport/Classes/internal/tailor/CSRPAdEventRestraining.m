//
//  CSRPAdEventRestraining.m
//
#import "CSRPAdEventRestraining.h"
#import "CSRPAdEventTypeRegistry.h"

@implementation CSRPAdEventStrictRestraint {
    NSDictionary<CSRPAdEventTypeEntry*, NSNumber*>* _dic;
}

- (instancetype)initWithDictionary:(NSDictionary<CSRPAdEventTypeEntry*, NSNumber*>*)dic {
    self = [super init];
    if (self)
        self->_dic = dic.copy;
    return self;
}

#pragma mark class property
static NSTimeInterval s_intervalRegardedAsSame = 10.0;
+ (NSTimeInterval)intervalRegardedAsSame {
    return s_intervalRegardedAsSame;
}
+ (void)setIntervalRegardedAsSame:(NSTimeInterval)intervalRegardedAsSame {
    s_intervalRegardedAsSame = intervalRegardedAsSame;
}

#pragma mark @protocol CSRPAdEventRestraining
- (BOOL)wildlyMatchesWithEvent:(CSRPAdEventTypeEntry *)event { return NO; }
- (id<CSRPAdEventRestraining>)updatedWithEvent:(CSRPAdEventTypeEntry *)event logAt:(double)logAt {
    NSNumber* const time = self->_dic[event];
    if (time && logAt - time.doubleValue <= self.class.intervalRegardedAsSame)
        return nil;
    NSMutableDictionary* const dic = self->_dic.mutableCopy ?: NSMutableDictionary.new;
    dic[event] = @(logAt);
    return [self.class.alloc initWithDictionary:dic];
}

@end

#if 0
@implementation CSRPAdEventSameAllRestraint

- (BOOL)wildlyMatchesWithEvent:(CSRPAdEventTypeEntry *)event {
}
- (id)updatedWithEvent:(CSRPAdEventTypeEntry *)event logAt:(double)logAt {
    if ([self wildlyMatchesWith:event])
        return nil;
    // create updated
    return updated;
}

@end
#endif
