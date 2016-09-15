#import <Foundation/Foundation.h>

#import <ChatCore/MVAvailability.h>
#import <ChatCore/MVChatString.h>
#import <ChatCore/MVMessaging.h>


NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, MVChatRoomMode) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVChatRoom, Mode, _val)
	MVChatRoomNoModes = 0,
	MVEnumVal(Private, 1 << 0),
	MVEnumVal(Secret, 1 << 1),
	MVEnumVal(InviteOnly, 1 << 2),
	MVEnumVal(NormalUsersSilenced, 1 << 3),
	MVEnumVal(OperatorsSilenced, 1 << 4),
	MVEnumVal(OperatorsOnlySetTopic, 1 << 5),
	MVEnumVal(NoOutsideMessages, 1 << 6),
	MVEnumVal(PassphraseToJoin, 1 << 7),
	MVEnumVal(LimitNumberOfMembers, 1 << 8)
#undef MVEnumVal
};

typedef NS_OPTIONS(NSUInteger, MVChatRoomMemberMode) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVChatRoomMember, Mode, _val)
	MVChatRoomMemberNoModes = 0,
	MVEnumVal(Voiced, 1 << 0),
	MVEnumVal(HalfOperator, 1 << 1),
	MVEnumVal(Operator, 1 << 2),
	MVEnumVal(Administrator, 1 << 3),
	MVEnumVal(Founder, 1 << 4)
#undef MVEnumVal
};

typedef NS_OPTIONS(NSUInteger, MVChatRoomMemberDisciplineMode) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVChatRoomMemberDiscipline, Mode, _val)
	MVChatRoomMemberNoDisciplineModes = 0,
	MVEnumVal(Quieted, 1 << 0)
#undef MVEnumVal
};

extern NSString *MVChatRoomMemberQuietedFeature;
extern NSString *MVChatRoomMemberVoicedFeature;
extern NSString *MVChatRoomMemberHalfOperatorFeature;
extern NSString *MVChatRoomMemberOperatorFeature;
extern NSString *MVChatRoomMemberAdministratorFeature;
extern NSString *MVChatRoomMemberFounderFeature;

extern NSString *MVChatRoomJoinedNotification;
extern NSString *MVChatRoomPartedNotification;
extern NSString *MVChatRoomKickedNotification;
extern NSString *MVChatRoomInvitedNotification;

extern NSString *MVChatRoomMemberUsersSyncedNotification;
extern NSString *MVChatRoomBannedUsersSyncedNotification;

extern NSString *MVChatRoomUserJoinedNotification;
extern NSString *MVChatRoomUserPartedNotification;
extern NSString *MVChatRoomUserKickedNotification;
extern NSString *MVChatRoomUserBannedNotification;
extern NSString *MVChatRoomUserBanRemovedNotification;
extern NSString *MVChatRoomUserModeChangedNotification;
extern NSString *MVChatRoomUserBrickedNotification;

extern NSString *MVChatRoomGotMessageNotification;
extern NSString *MVChatRoomTopicChangedNotification;
extern NSString *MVChatRoomModesChangedNotification;
extern NSString *MVChatRoomAttributeUpdatedNotification;

@class MVChatConnection;
@class MVChatUser;

@interface MVChatRoom : NSObject <MVMessaging> {
@protected
	__weak MVChatConnection *_connection;
	id _uniqueIdentifier;
	NSString *_name;
	NSDate *_dateJoined;
	NSDate *_dateParted;
	NSDate *_mostRecentUserActivity;
	NSData *_topic;
	MVChatUser *_topicAuthor;
	NSDate *_dateTopicChanged;
	NSMutableDictionary *_attributes;
	NSMutableSet *_memberUsers;
	NSMutableSet *_bannedUsers;
	NSMutableDictionary *_modeAttributes;
	NSMutableDictionary *_memberModes;
	NSMutableDictionary *_disciplineMemberModes;
	NSStringEncoding _encoding;
	NSUInteger _modes;
	NSUInteger _hash;
	BOOL _releasing;
}
@property(weak, nullable, readonly) MVChatConnection *connection;

@property(strong, readonly, nullable) NSURL *url;
@property(strong, readonly) NSString *name;
@property(strong, readonly) NSString *displayName;
@property(strong, readonly) id uniqueIdentifier;

@property(readonly, getter=isJoined) BOOL joined;
@property(strong, readonly) NSDate *dateJoined;
@property(strong, readonly) NSDate *dateParted;
@property(nonatomic, copy) NSDate *mostRecentUserActivity;

@property NSStringEncoding encoding;

@property(copy, readonly) NSData *topic;
@property(strong, readonly) MVChatUser *topicAuthor;
@property(copy, readonly) NSDate *dateTopicChanged;

@property(strong, readonly) NSSet<NSString*> *supportedAttributes;
@property(strong, readonly) NSDictionary *attributes;

@property(readonly) NSUInteger supportedModes;
@property(readonly) NSUInteger supportedMemberUserModes;
@property(readonly) NSUInteger supportedMemberDisciplineModes;
@property(readonly) NSUInteger modes;

@property(strong, readonly) MVChatUser *localMemberUser;
@property(strong, readonly) NSSet<MVChatUser*> *memberUsers;
@property(strong, readonly) NSSet<MVChatUser*> *bannedUsers;

- (BOOL) isEqual:(nullable id) object;
- (BOOL) isEqualToChatRoom:(MVChatRoom *) anotherUser;

- (NSComparisonResult) compare:(MVChatRoom *) otherRoom;
- (NSComparisonResult) compareByUserCount:(MVChatRoom *) otherRoom;

- (void) join;
- (void) part;

- (void) partWithReason:(MVChatString * __nullable) reason;

- (void) changeTopic:(MVChatString *) topic;

- (void) sendMessage:(MVChatString *) message asAction:(BOOL) action;
- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding asAction:(BOOL) action;
- (void) sendMessage:(MVChatString *) message withEncoding:(NSStringEncoding) encoding withAttributes:(NSDictionary *) attributes;

- (void) sendCommand:(NSString *) command withArguments:(MVChatString *) arguments;
- (void) sendCommand:(NSString *) command withArguments:(MVChatString *) arguments withEncoding:(NSStringEncoding) encoding;

- (void) sendSubcodeRequest:(NSString *) command withArguments:(id) arguments;
- (void) sendSubcodeReply:(NSString *) command withArguments:(id) arguments;

- (void) refreshAttributes;
- (void) refreshAttributeForKey:(NSString *) key;

- (BOOL) hasAttributeForKey:(NSString *) key;
- (id __nullable) attributeForKey:(NSString *) key;
- (void) setAttribute:(id __nullable) attribute forKey:(id) key;

- (id) attributeForMode:(MVChatRoomMode) mode;

- (void) setModes:(NSUInteger) modes;
- (void) setMode:(MVChatRoomMode) mode;
- (void) setMode:(MVChatRoomMode) mode withAttribute:(id __nullable) attribute;
- (void) removeMode:(MVChatRoomMode) mode;

- (NSSet<MVChatUser*> *) memberUsersWithModes:(NSUInteger) modes;
- (nullable NSSet<MVChatUser*> *) memberUsersWithNickname:(NSString *) nickname;
- (NSSet<MVChatUser*> *) memberUsersWithFingerprint:(NSString *) fingerprint;
- (MVChatUser *) memberUserWithUniqueIdentifier:(id) identifier;
- (BOOL) hasUser:(MVChatUser *) user;

- (void) kickOutMemberUser:(MVChatUser *) user forReason:(MVChatString * __nullable) reason;

- (void) addBanForUser:(MVChatUser *) user;
- (void) removeBanForUser:(MVChatUser *) user;

- (NSUInteger) modesForMemberUser:(MVChatUser *) user;
- (NSUInteger) disciplineModesForMemberUser:(MVChatUser *) user;

- (void) setModes:(NSUInteger) modes forMemberUser:(MVChatUser *) user;
- (void) setMode:(MVChatRoomMemberMode) mode forMemberUser:(MVChatUser *) user;
- (void) removeMode:(MVChatRoomMemberMode) mode forMemberUser:(MVChatUser *) user;

- (void) setDisciplineMode:(MVChatRoomMemberDisciplineMode) mode forMemberUser:(MVChatUser *) user;
- (void) removeDisciplineMode:(MVChatRoomMemberDisciplineMode) mode forMemberUser:(MVChatUser *) user;

- (void) requestRecentActivity;
- (void) persistLastActivityDate;
@end

#pragma mark -

#if ENABLE(SCRIPTING)
@interface MVChatRoom (MVChatRoomScripting)
@property(readonly) NSString *scriptUniqueIdentifier;
@property(readonly) NSScriptObjectSpecifier *objectSpecifier;
@end
#endif

NS_ASSUME_NONNULL_END
