#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT extern NSString *const MVChatPluginManagerWillReloadPluginsNotification;
COLLOQUY_EXPORT extern NSString *const MVChatPluginManagerDidReloadPluginsNotification;
COLLOQUY_EXPORT extern NSString *const MVChatPluginManagerDidFindInvalidPluginsNotification;

@protocol MVChatPlugin;

COLLOQUY_EXPORT
@interface MVChatPluginManager : NSObject {
	@private
	NSMutableArray<id<MVChatPlugin>> *_plugins;
	NSMutableDictionary<NSString*,NSString*> *_invalidPlugins;
	BOOL _reloadingPlugins;
}
@property (readonly, strong, class) MVChatPluginManager *defaultManager;
@property (readonly, copy, class) NSArray<NSString*> *pluginSearchPaths;

@property(copy, readonly) NSArray<id<MVChatPlugin>> *plugins;

- (void) reloadPlugins;
- (void) addPlugin:(id <MVChatPlugin>) plugin;
- (void) removePlugin:(id <MVChatPlugin>) plugin;

- (NSArray<id<MVChatPlugin>> *) pluginsThatRespondToSelector:(SEL) selector;
- (NSArray<id<MVChatPlugin>> *) pluginsOfClass:(Class __nullable) class thatRespondToSelector:(SEL) selector;

- (nullable NSArray *) makePluginsPerformInvocation:(NSInvocation *) invocation;
- (nullable NSArray *) makePluginsPerformInvocation:(NSInvocation *) invocation stoppingOnFirstSuccessfulReturn:(BOOL) stop;
- (nullable NSArray *) makePluginsOfClass:(Class __nullable) class performInvocation:(NSInvocation *) invocation stoppingOnFirstSuccessfulReturn:(BOOL) stop;
@end

@protocol MVChatPlugin <NSObject>
- (null_unspecified instancetype) initWithManager:(MVChatPluginManager *) manager;

#pragma mark MVChatPluginReloadSupport
@optional
- (void) load;
- (void) unload;
@end

NS_ASSUME_NONNULL_END
