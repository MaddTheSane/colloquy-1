#import "KAIgnoreRule.h"

@class MVChatConnection;
@class MVChatRoom;
@class MVChatUser;
@class MVDirectChatConnection;
@class JVChatWindowController;
@class JVChatRoomPanel;
@class JVDirectChatPanel;
@class JVChatTranscriptPanel;
@class JVSmartTranscriptPanel;
@class JVChatConsolePanel;

@protocol JVChatViewController;

NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT
@interface JVChatController : NSObject {
	@private
	NSMutableSet *_chatWindows;
	NSMutableSet *_chatControllers;
	NSArray *_windowRuleSets;
}
+ (JVChatController *) defaultController;
+ (NSMenu *) smartTranscriptMenu;
+ (void) refreshSmartTranscriptMenu;

- (void) addViewControllerToPreferedWindowController:(id <JVChatViewController>) controller userInitiated:(BOOL) initiated;

@property (readonly, copy) NSSet<JVChatWindowController*> *allChatWindowControllers;
- (JVChatWindowController * _Nullable) createChatWindowController;
- (JVChatWindowController *) chatWindowControllerWithIdentifier:(NSString *) identifier;
- (void) disposeChatWindowController:(JVChatWindowController *) controller;

@property (readonly, copy) NSSet<id <JVChatViewController>> *allChatViewControllers;
- (NSSet<id <JVChatViewController>> *) chatViewControllersWithConnection:(MVChatConnection *) connection;
- (NSSet<id <JVChatViewController>> *) chatViewControllersOfClass:(Class) class;
- (NSSet<id <JVChatViewController>> *) chatViewControllersKindOfClass:(Class) class;

- (JVChatRoomPanel * _Nullable) chatViewControllerForRoom:(MVChatRoom *) room ifExists:(BOOL) exists;
- (JVDirectChatPanel * _Nullable) chatViewControllerForUser:(MVChatUser *) user ifExists:(BOOL) exists;
- (JVDirectChatPanel * _Nullable) chatViewControllerForUser:(MVChatUser *) user ifExists:(BOOL) exists userInitiated:(BOOL) requested;
- (JVDirectChatPanel * _Nullable) chatViewControllerForDirectChatConnection:(MVDirectChatConnection *) connection ifExists:(BOOL) exists;
- (JVDirectChatPanel *_Nullable ) chatViewControllerForDirectChatConnection:(MVDirectChatConnection *) connection ifExists:(BOOL) exists userInitiated:(BOOL) initiated;
- (JVChatTranscriptPanel * _Nullable) chatViewControllerForTranscript:(NSString *) filename;
- (JVChatConsolePanel * _Nullable) chatConsoleForConnection:(MVChatConnection *) connection ifExists:(BOOL) exists;

- (JVSmartTranscriptPanel *) createSmartTranscript;
@property (readonly, copy) NSSet<JVSmartTranscriptPanel*> *smartTranscripts;
- (void) saveSmartTranscripts;
- (void) disposeSmartTranscript:(JVSmartTranscriptPanel *) panel;

- (void) disposeViewController:(id <JVChatViewController>) controller;
- (void) detachViewController:(id <JVChatViewController>) controller;

- (IBAction) detachView:(nullable id) sender;

- (JVIgnoreMatchResult) shouldIgnoreUser:(MVChatUser *) user withMessage:(nullable NSAttributedString *) message inView:(nullable id <JVChatViewController>) view;
@end

@interface NSObject (MVChatPluginCommandSupport)
- (BOOL) processUserCommand:(NSString *) command withArguments:(NSAttributedString *) arguments toConnection:(nullable MVChatConnection *) connection inView:(nullable id <JVChatViewController>) view;
@end

NS_ASSUME_NONNULL_END
