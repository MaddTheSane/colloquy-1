#import <Foundation/NSNotification.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (NSNotificationCenterAdditions)
@property (class, readonly, strong) NSNotificationCenter *chatCenter;

- (void) postNotificationOnMainThread:(NSNotification *) notification NS_SWIFT_NAME(postNotificationOnMainThread(_:));
- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait NS_SWIFT_NAME(postNotificationOnMainThread(_:waitUntilDone:));

- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object;
- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object userInfo:(NSDictionary * __nullable) userInfo;
- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object userInfo:(NSDictionary * __nullable) userInfo waitUntilDone:(BOOL) wait;
@end

NS_ASSUME_NONNULL_END
