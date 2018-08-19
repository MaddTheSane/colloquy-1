#import <ChatCore/MVChatPluginManager.h>

COLLOQUY_EXPORT
@interface JVJavaScriptPluginLoader : NSObject <MVChatPlugin> {
	__unsafe_unretained MVChatPluginManager *_manager;
}
- (void) loadPluginNamed:(NSString *) name;
@end
