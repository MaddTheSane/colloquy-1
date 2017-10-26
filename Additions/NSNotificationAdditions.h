NS_ASSUME_NONNULL_BEGIN

@interface NSNotificationCenter (NSNotificationCenterAdditions)
+ (NSNotificationCenter *) chatCenter;

- (void) postNotificationOnMainThread:(NSNotification *) notification;
- (void) postNotificationOnMainThread:(NSNotification *) notification waitUntilDone:(BOOL) wait;

- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object;
- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object userInfo:(NSDictionary * __nullable) userInfo;
- (void) postNotificationOnMainThreadWithName:(NSNotificationName) name object:(id __nullable) object userInfo:(NSDictionary * __nullable) userInfo waitUntilDone:(BOOL) wait;
@end

NS_ASSUME_NONNULL_END
