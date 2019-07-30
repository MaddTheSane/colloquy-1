#import <Foundation/Foundation.h>

#import "MVAvailability.h"
#import "MVChatString.h"
#import "MVMessaging.h"


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(OSType, MVChatUserType) {
	MVChatRemoteUserType = 'remT',
	MVChatLocalUserType = 'locL',
	MVChatWildcardUserType = 'wilD'
};

typedef NS_ENUM(OSType, MVChatUserStatus) {
	MVChatUserUnknownStatus = 'uKnw',
	MVChatUserOfflineStatus = 'oflN',
	MVChatUserDetachedStatus = 'detA',
	MVChatUserAvailableStatus = 'avaL',
	MVChatUserAwayStatus = 'awaY'
};

typedef NS_OPTIONS(NSUInteger, MVChatUserMode) {
	MVChatUserNoModes = 0,
	MVChatUserInvisibleMode = 1 << 0
};

typedef NSString *MVChatUserAttributeKey NS_TYPED_EXTENSIBLE_ENUM;

COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserKnownRoomsAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPictureAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPingAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserLocalTimeAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserClientInfoAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserVCardAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserServiceAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserMoodAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserStatusMessageAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPreferredLanguageAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPreferredContactMethodsAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserTimezoneAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserGeoLocationAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserDeviceInfoAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserExtensionAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPublicKeyAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserServerPublicKeyAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserDigitalSignatureAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserServerDigitalSignatureAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserBanServerAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserBanAuthorAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserBanDateAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserSSLCertFingerprintAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserEmailAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserPhoneAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserWebsiteAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserIMServiceAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserCurrentlyPlayingAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserStatusAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserClientNameAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserClientVersionAttribute;
COLLOQUY_EXPORT extern MVChatUserAttributeKey const MVChatUserClientUnknownAttributes;

COLLOQUY_EXPORT extern NSString *const MVChatUserNicknameChangedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserStatusChangedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserAwayStatusMessageChangedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserIdleTimeUpdatedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserModeChangedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserInformationUpdatedNotification;
COLLOQUY_EXPORT extern NSString *const MVChatUserAttributeUpdatedNotification;

@class MVChatConnection;
@class MVUploadFileTransfer;

COLLOQUY_EXPORT
@interface MVChatUser : NSObject <MVMessaging> {
@protected
	__weak MVChatConnection *_connection;
	id _uniqueIdentifier;
	NSString *_nickname;
	NSString *_realName;
	NSString *_username;
	NSString *_account;
	NSString *_address;
	NSString *_serverAddress;
	NSData *_publicKey;
	NSString *_fingerprint;
	NSDate *_dateConnected;
	NSDate *_dateDisconnected;
	NSDate *_dateUpdated;
	NSData *_awayStatusMessage;
	NSDate *_mostRecentUserActivity;
	NSMutableDictionary<MVChatUserAttributeKey,id> *_attributes;
	MVChatUserType _type;
	MVChatUserStatus _status;
	NSTimeInterval _idleTime;
	NSTimeInterval _lag;
	NSUInteger _modes;
	NSUInteger _hash;
	BOOL _identified;
	BOOL _serverOperator;
	BOOL _onlineNotificationSent;
}
+ (MVChatUser*) wildcardUserFromString:(NSString *) mask;
+ (MVChatUser*) wildcardUserWithNicknameMask:(NSString * __nullable) nickname andHostMask:(NSString * __nullable) host;
+ (MVChatUser*) wildcardUserWithFingerprint:(NSString *) fingerprint;

@property(weak, nullable, readonly) MVChatConnection *connection;
@property(readonly) MVChatUserType type;

@property(readonly, getter=isRemoteUser) BOOL remoteUser;
@property(readonly, getter=isLocalUser) BOOL localUser;
@property(readonly, getter=isWildcardUser) BOOL wildcardUser;

@property(readonly, getter=isIdentified) BOOL identified;
@property(readonly, getter=isServerOperator) BOOL serverOperator;

@property(nonatomic, readonly) MVChatUserStatus status;
@property(copy, readonly) NSData *awayStatusMessage;

@property(copy, readonly) NSDate *dateConnected;
@property(copy, readonly) NSDate *dateDisconnected;
@property(copy, readonly) NSDate *dateUpdated;
@property(nonatomic, copy) NSDate *mostRecentUserActivity;

@property(nonatomic, readonly) NSTimeInterval idleTime;
@property(readonly) NSTimeInterval lag;

@property(copy, readonly) NSString *displayName;
@property(nullable, copy, readonly) NSString *nickname;
@property(nullable, copy, readonly) NSString *realName;
@property(nullable, copy, readonly) NSString *username;
@property(nullable, copy, readonly) NSString *account;
@property(copy, readonly) NSString *address;
@property(nullable, copy, readonly) NSString *serverAddress;
@property(copy, readonly, nullable) NSString *maskRepresentation;

@property(nonatomic, strong, readonly) id uniqueIdentifier;
@property(copy, readonly) NSData *publicKey;
@property(copy, readonly) NSString *fingerprint;

@property(readonly) NSUInteger supportedModes;
@property(readonly) NSUInteger modes;

@property(strong, readonly) NSSet<MVChatUserAttributeKey> *supportedAttributes;
@property(strong, readonly) NSDictionary<MVChatUserAttributeKey,id> *attributes;

- (BOOL) isEqual:(nullable id) object;
- (BOOL) isEqualToChatUser:(MVChatUser *) anotherUser;

- (NSComparisonResult) compare:(MVChatUser *) otherUser;
- (NSComparisonResult) compareByNickname:(MVChatUser *) otherUser;
- (NSComparisonResult) compareByUsername:(MVChatUser *) otherUser;
- (NSComparisonResult) compareByAddress:(MVChatUser *) otherUser;
- (NSComparisonResult) compareByRealName:(MVChatUser *) otherUser;
- (NSComparisonResult) compareByIdleTime:(MVChatUser *) otherUser;

- (void) refreshInformation;

- (void) refreshAttributes;
- (void) refreshAttributeForKey:(MVChatUserAttributeKey) key;

- (BOOL) hasAttributeForKey:(MVChatUserAttributeKey) key;
- (id __nullable) attributeForKey:(MVChatUserAttributeKey) key;
- (void) setAttribute:(id __nullable) attribute forKey:(MVChatUserAttributeKey) key;

- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding asAction:(BOOL) action;
- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding withAttributes:(NSDictionary<NSString*,id> *) attributes;

- (void) sendCommand:(NSString *) command withArguments:(MVChatString *) arguments withEncoding:(NSStringEncoding) encoding;

- (MVUploadFileTransfer *) sendFile:(NSString *) path passively:(BOOL) passive;

- (void) sendSubcodeRequest:(NSString *) command withArguments:(id __nullable) arguments;
- (void) sendSubcodeReply:(NSString *) command withArguments:(id __nullable) arguments;

- (void) requestRecentActivity;
- (void) persistLastActivityDate;
@end

#pragma mark -

#if ENABLE(SCRIPTING)
@interface MVChatUser (MVChatUserScripting)
@property(readonly) NSString *scriptUniqueIdentifier;
@property(readonly) NSScriptObjectSpecifier *objectSpecifier;
@end
#endif

NS_ASSUME_NONNULL_END
