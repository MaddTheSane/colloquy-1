NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT
@interface JVNotificationController : NSObject <NSUserNotificationCenterDelegate> {
	NSMutableDictionary *_bubbles;
	NSMutableDictionary *_sounds;
	BOOL _useGrowl;
}
+ (JVNotificationController *) defaultController;
- (void) performNotification:(NSString *) identifier withContextInfo:(NSDictionary<NSString*,id> * _Nullable) context;
@end

@interface NSObject (MVChatPluginNotificationSupport)
- (void) performNotification:(NSString *) identifier withContextInfo:(nullable NSDictionary<NSString*,id> *) context andPreferences:(nullable NSDictionary<NSString*,id> *) preferences;
@end

NS_ASSUME_NONNULL_END
