//
//  CSRPAdEventTypeRegistry.m
//
#import "CSRPAdEventTypeRegistry.h"

@interface CSRPAdEventTypeEntry ()
#pragma mark protocol CSRPAdEventTypeEntry
@property (nonatomic, readonly, nonnull) NSString* name;
@property (nonatomic, readonly) NSInteger number;
@end
@implementation CSRPAdEventTypeEntry

enum {
    eBuiltInBit = 0,
    eNumberBits = 1,
};

static CSRPAdEventTypeEntry* pr_newEntry(NSString* name, NSInteger number, BOOL builtIn) {
    CSRPAdEventTypeEntry* const entry = CSRPAdEventTypeEntry.new;
    if (entry) {
        entry->_name = name;
        entry->_number = number;
        entry->_uniqueId = 0
            | ((!!builtIn) << eBuiltInBit)
            | (number << eNumberBits)
            ;
    //  NSAssert(0 <= number, @"0 <= number");
        if (number < 0)
            NSLog(@"%s: %@", __func__, @"assertion failed");
    }
    return entry;
}

- (BOOL)isBuiltIn { return self->_uniqueId & (1 << eBuiltInBit); }

#pragma mark override NSObject
- (NSUInteger)hash { return self->_uniqueId; }

#pragma mark protocol NSCopying
- (id)copyWithZone:(NSZone *)zone { return self; }

#pragma mark - protocol CSRPAdEventTypeEntry
- (BOOL)is_impression       { return _number == CSRPAdEventType_impression; }
- (BOOL)is_start            { return _number == CSRPAdEventType_start; }
- (BOOL)is_firstQuartile    { return _number == CSRPAdEventType_firstQuartile; }
- (BOOL)is_midpoint         { return _number == CSRPAdEventType_midpoint; }
- (BOOL)is_thirdQuartile    { return _number == CSRPAdEventType_thirdQuartile; }
- (BOOL)is_complete         { return _number == CSRPAdEventType_complete; }

@end

#pragma mark -
@implementation CSRPAdEventTypeRegistry {
    NSArray<CSRPAdEventTypeEntry*>* _builtins;
    NSDictionary<NSString*, CSRPAdEventTypeEntry*>* _flies;
}

- (CSRPAdEventTypeEntry *)objectForKeyedSubscript:(NSString *)name {
    return !name ? nil : self->_flies[name];
}

- (CSRPAdEventTypeEntry *)builtInEntryAt:(CSRPAdEventTypeEnum)number {
    if (number <= CSRPAdEventType_NOTHING || self->_builtins.count <= number)
        return nil;
    return self->_builtins[number];
}

static CSRPAdEventTypeRegistry* pr_createDefault() {
    NSArray<NSString*>* const names =
    @[
        @"impression",
        @"start",
        @"firstQuartile",
        @"midpoint",
        @"thirdQuartile",
        @"complete",
    ];
    NSMutableDictionary<NSString*, CSRPAdEventTypeEntry*>* const flies = NSMutableDictionary.new;
    NSMutableArray<CSRPAdEventTypeEntry*>* const builtIns = NSMutableArray.new;
    [builtIns addObject:CSRPAdEventTypeEntry.new];  // [0]: CSRPAdEventType_NOTHING
    for (NSString* it in names) {
        [builtIns addObject:pr_newEntry(it, builtIns.count, YES)];
        flies[it] = pr_newEntry(it, flies.count + 1, NO);
    }
    CSRPAdEventTypeRegistry* const reg = CSRPAdEventTypeRegistry.new;
    reg->_builtins = builtIns.copy;
    reg->_flies = flies.copy;
    return reg;
}

+ (instancetype)sharedRegistry {
    static CSRPAdEventTypeRegistry* s_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = pr_createDefault();
    });
    return s_instance;
}

@end
