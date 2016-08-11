#import "MVChatConnection.h"
#import "MVChatConnectionPrivate.h"

@class XMPPStream;
@class XMPPJID;
@class XMPPElement;

NS_ASSUME_NONNULL_BEGIN

@interface MVXMPPChatConnection : MVChatConnection {
@private
	XMPPStream *_session;
	XMPPJID *_localID;
	unsigned short _serverPort;
	NSString *_server;
	NSString *_username;
	NSString *_nickname;
	NSString *_password;
}
+ (NSArray <NSNumber*> *) defaultServerPorts;
+ (NSUInteger) maxMessageLength;
#if __has_feature(objc_class_property)
@property (readonly, class, copy) NSArray<NSNumber*> *defaultServerPorts;
@property (readonly, class) NSUInteger maxMessageLength;
#endif
@end

@interface MVXMPPChatConnection (MVXMPPChatConnectionPrivate)
- (XMPPStream *) _chatSession;
- (XMPPJID *) _localUserID;
- (XMPPElement *) _capabilitiesElement;
- (XMPPElement *) _multiUserChatExtensionElement;
@end

NS_ASSUME_NONNULL_END
