#import <Foundation/Foundation.h>

#import "MVChatConnection.h"
#import "MVMessaging.h"


NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT extern NSNotificationName MVDirectChatConnectionOfferNotification;

COLLOQUY_EXPORT extern NSNotificationName MVDirectChatConnectionDidConnectNotification;
COLLOQUY_EXPORT extern NSNotificationName MVDirectChatConnectionDidDisconnectNotification;
COLLOQUY_EXPORT extern NSNotificationName MVDirectChatConnectionErrorOccurredNotification;

COLLOQUY_EXPORT extern NSNotificationName MVDirectChatConnectionGotMessageNotification;

COLLOQUY_EXPORT extern NSErrorDomain MVDirectChatConnectionErrorDomain;

typedef NS_ENUM(OSType, MVDirectChatConnectionStatus) {
	MVDirectChatConnectionConnectedStatus NS_SWIFT_NAME(connected) = 'dcCo',
	MVDirectChatConnectionWaitingStatus NS_SWIFT_NAME(waiting) = 'dcWa',
	MVDirectChatConnectionDisconnectedStatus NS_SWIFT_NAME(disconnected) = 'dcDs',
	MVDirectChatConnectionErrorStatus NS_SWIFT_NAME(error) = 'dcEr'
};

@class MVChatUser;

COLLOQUY_EXPORT
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

@property NSStringEncoding encoding NS_REFINED_FOR_SWIFT;

@property MVChatMessageFormat outgoingChatFormat;

- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding asAction:(BOOL) action;
- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding withAttributes:(NSDictionary<NSString*,id> *)attributes;
@end

NS_ASSUME_NONNULL_END
