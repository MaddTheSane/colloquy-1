#import <ChatCore/MVChatPluginManager.h>

COLLOQUY_EXPORT
@interface JVAppleScriptPluginLoader : NSObject <MVChatPlugin> {
	__weak MVChatPluginManager *_manager;
}
@end
