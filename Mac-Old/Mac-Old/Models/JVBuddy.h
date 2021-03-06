#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const JVBuddyCameOnlineNotification;
extern NSNotificationName const JVBuddyWentOfflineNotification;

extern NSNotificationName const JVBuddyUserCameOnlineNotification;
extern NSNotificationName const JVBuddyUserWentOfflineNotification;
extern NSNotificationName const JVBuddyUserStatusChangedNotification;
extern NSNotificationName const JVBuddyUserIdleTimeUpdatedNotification;

extern NSNotificationName const JVBuddyActiveUserChangedNotification;

@class ABPerson;
@class MVChatUser;

typedef NS_ENUM(NSInteger, JVBuddyName) {
	JVBuddyActiveNickname = 0x0,
	JVBuddyGivenNickname = 0x1,
	JVBuddyFullName = 0x2
};

@interface JVBuddy : NSObject
@property (readwrite, class) JVBuddyName preferredName;

- (instancetype) init NS_DESIGNATED_INITIALIZER;
- (instancetype) initWithDictionaryRepresentation:(NSDictionary<NSString*,id> *) dictionary;
- (NSDictionary<NSString*,id> *) dictionaryRepresentation;

- (void) registerWithConnection:(MVChatConnection *) connection;
- (void) registerWithApplicableConnections;
- (void) unregisterWithConnection:(MVChatConnection *) connection;
- (void) unregisterWithConnections;

@property (nonatomic, strong, nullable) MVChatUser *activeUser;

@property (readonly) MVChatUserStatus status;
@property (readonly) NSData *awayStatusMessage;

@property (readonly, getter=isOnline) BOOL online;
@property (readonly) NSDate *dateConnected;
@property (readonly) NSDate *dateDisconnected;

@property (readonly) NSTimeInterval idleTime;

@property (readonly, copy) NSString *displayName;
@property (readonly, copy) NSString *nickname;

@property (readonly, copy) NSSet<MVChatUser*> *users;

@property (readonly, copy) NSArray<MVChatUserWatchRule*> *watchRules;
- (void) addWatchRule:(MVChatUserWatchRule *) rule;
- (void) removeWatchRule:(MVChatUserWatchRule *) rule;

@property (nonatomic, copy, nullable) NSImage *picture;
@property (readonly, copy) NSString *compositeName;
@property (nonatomic, copy, nullable) NSString *firstName;
@property (nonatomic, copy, nullable) NSString *lastName;
@property (nonatomic, copy, nullable) NSString *primaryEmail;
@property (nonatomic, copy, nullable) NSString *givenNickname;
@property (copy, nullable) NSString *speechVoice;
@property (readonly, copy) NSString *uniqueIdentifier;

@property (strong, nullable) ABPerson *addressBookPersonRecord;
- (void) editInAddressBook;
- (void) viewInAddressBook;

- (NSComparisonResult) availabilityCompare:(JVBuddy *) buddy;
- (NSComparisonResult) firstNameCompare:(JVBuddy *) buddy;
- (NSComparisonResult) lastNameCompare:(JVBuddy *) buddy;
- (NSComparisonResult) serverCompare:(JVBuddy *) buddy;
- (NSComparisonResult) nicknameCompare:(JVBuddy *) buddy;
@end

NS_ASSUME_NONNULL_END
