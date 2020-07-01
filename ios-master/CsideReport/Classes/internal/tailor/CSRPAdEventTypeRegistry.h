//
//  CSRPAdEventTypeRegistry.h
//
#import <Foundation/Foundation.h>
#import "CSRPAdEventTypeEntry.h"

/**
 * Fly-weight to identify event-type, including built-in
 */
@interface CSRPAdEventTypeEntry : NSObject <CSRPAdEventTypeEntry, NSCopying>
@property (nonatomic, readonly) NSUInteger uniqueId;
- (BOOL)isBuiltIn;
@end

@interface CSRPAdEventTypeRegistry : NSObject

/**
 * Registry with [ impression | start | ... | complete ]
 */
+ (nonnull instancetype)sharedRegistry;

/**
 * Returns non-built-in entry with name, if registered.  Otherwise nil.
 */
- (nullable CSRPAdEventTypeEntry*)objectForKeyedSubscript:(nullable NSString*)name;

- (nullable CSRPAdEventTypeEntry*)builtInEntryAt:(CSRPAdEventTypeEnum)number;

@end
