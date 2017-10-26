NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT extern NSString *MVChatPluginManagerWillReloadPluginsNotification;
COLLOQUY_EXPORT extern NSString *MVChatPluginManagerDidReloadPluginsNotification;
COLLOQUY_EXPORT extern NSString *MVChatPluginManagerDidFindInvalidPluginsNotification;

@protocol MVChatPlugin;

COLLOQUY_EXPORT
@interface MVChatPluginManager : NSObject {
	@private
	NSMutableArray *_plugins;
	NSMutableDictionary *_invalidPlugins;
	BOOL _reloadingPlugins;
}
@property (readonly, strong, class) MVChatPluginManager *defaultManager;
@property (readonly, copy, class) NSArray<NSString*> *pluginSearchPaths;

@property(strong, readonly) NSArray<id<MVChatPlugin>> *plugins;

- (void) reloadPlugins;
- (void) addPlugin:(id <MVChatPlugin>) plugin;
- (void) removePlugin:(id <MVChatPlugin>) plugin;

- (NSArray<id<MVChatPlugin>> *) pluginsThatRespondToSelector:(SEL) selector;
- (NSArray<id<MVChatPlugin>> *) pluginsOfClass:(Class __nullable) class thatRespondToSelector:(SEL) selector;

- (NSArray *) makePluginsPerformInvocation:(NSInvocation *) invocation;
- (NSArray *) makePluginsPerformInvocation:(NSInvocation *) invocation stoppingOnFirstSuccessfulReturn:(BOOL) stop;
- (NSArray *) makePluginsOfClass:(Class __nullable) class performInvocation:(NSInvocation *) invocation stoppingOnFirstSuccessfulReturn:(BOOL) stop;
@end

@protocol MVChatPlugin <NSObject>
- (null_unspecified instancetype) initWithManager:(MVChatPluginManager *) manager;

#pragma mark MVChatPluginReloadSupport
@optional
- (void) load;
- (void) unload;
@end

NS_ASSUME_NONNULL_END
