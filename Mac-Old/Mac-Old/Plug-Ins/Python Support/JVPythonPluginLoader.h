#import <ChatCore/MVChatPluginManager.h>

COLLOQUY_EXPORT
@interface JVPythonPluginLoader : NSObject <MVChatPlugin> {
	__unsafe_unretained MVChatPluginManager *_manager;
	BOOL _pyobjcInstalled;
}
- (void) loadPluginNamed:(NSString *) name;
@end
