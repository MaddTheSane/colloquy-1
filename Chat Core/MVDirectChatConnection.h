#import <Foundation/Foundation.h>

#import "MVAvailability.h"
#import "MVChatConnection.h"
#import "MVMessaging.h"


NS_ASSUME_NONNULL_BEGIN

extern NSString *MVDirectChatConnectionOfferNotification;

extern NSString *MVDirectChatConnectionDidConnectNotification;
extern NSString *MVDirectChatConnectionDidDisconnectNotification;
extern NSString *MVDirectChatConnectionErrorOccurredNotification;

extern NSString *MVDirectChatConnectionGotMessageNotification;

extern NSString *MVDirectChatConnectionErrorDomain;

typedef NS_ENUM(OSType, MVDirectChatConnectionStatus) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVDirectChatConnection, Status, _val)
	MVEnumVal(Connected, 'dcCo'),
	MVEnumVal(Waiting, 'dcWa'),
	MVEnumVal(Disconnected, 'dcDs'),
	MVEnumVal(Error, 'dcEr'),
#undef MVEnumVal
};

@class MVChatUser;

@interface MVDirectChatConnection : NSObject <MVMessaging>
+ (instancetype) directChatConnectionWithUser:(MVChatUser *) user passively:(BOOL) passive;

@property (getter=isPassive, readonly) BOOL passive;
@property (readonly) MVDirectChatConnectionStatus status;

@property (readonly, strong) MVChatUser *user;
@property (readonly, copy) NSString *host;
@property (readonly, copy) NSString *connectedHost;
@property (readonly) unsigned short port;

- (void) initiate;
- (void) disconnect;

@property NSStringEncoding encoding;

@property MVChatMessageFormat outgoingChatFormat;

- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding asAction:(BOOL) action;
- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding withAttributes:(NSDictionary *)attributes;
@end

NS_ASSUME_NONNULL_END
