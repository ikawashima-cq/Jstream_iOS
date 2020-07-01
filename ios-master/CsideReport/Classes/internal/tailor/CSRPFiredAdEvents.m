//
//  CSRPFiredAdEvents.m
//
#import "CSRPFiredAdEvents.h"

@implementation CSRPFiredAdEvents {
    id<CSRPAdEventRestraining> _eventLogs;
}

- (instancetype)initWithAdLid:(CSRPAdLid *)adLid {
    self = [super init];
    if (self) {
        self->_adLid = adLid;
    }
    return self;
}
- (instancetype)initWithAdLid:(CSRPAdLid *)adLid
                    updatedAt:(NSTimeInterval)updatedAt
                    eventLogs:(id<CSRPAdEventRestraining>)eventLogs
{
    self = [super init];
    if (self) {
        self->_adLid = adLid;
        self->_updatedAt = updatedAt;
        self->_eventLogs = eventLogs;
    }
    return self;
}

- (id<CSRPAdEventRestraining>)eventLogs {
    return self->_eventLogs = self->_eventLogs ?: [self.class.eventLogsClass new];
}

#pragma mark class property
+ (Class)eventLogsClass { return CSRPAdEventStrictRestraint.class; }

#pragma mark @protocol CSRPAdEventRestraining
- (BOOL)wildlyMatchesWithEvent:(CSRPAdEventTypeEntry *)event {
    return [self.eventLogs wildlyMatchesWithEvent:event];
}
- (id<CSRPAdEventRestraining>)updatedWithEvent:(CSRPAdEventTypeEntry *)event logAt:(double)logAt {
    id<CSRPAdEventRestraining> updated = [self.eventLogs updatedWithEvent:event logAt:logAt];
    if (!updated)
        return nil;
    NSTimeInterval at = self.updatedAt;
    if (at < logAt)
        at = logAt;
    return [self.class.alloc initWithAdLid:self.adLid updatedAt:at eventLogs:updated];
}

@end
