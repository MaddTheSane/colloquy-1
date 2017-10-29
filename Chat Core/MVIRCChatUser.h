#import <Foundation/Foundation.h>

#import "MVChatUser.h"
#import "MVChatUserPrivate.h"


NS_ASSUME_NONNULL_BEGIN

@class MVIRCChatConnection;

@interface MVIRCChatUser : MVChatUser
@property (readonly, class, copy) NSArray<NSString*> *servicesNicknames;

- (instancetype) initLocalUserWithConnection:(MVIRCChatConnection *) connection;
- (instancetype) initWithNickname:(NSString *) nickname andConnection:(MVIRCChatConnection *) connection;
@end

@interface MVIRCChatUser (MVIRCChatUserPrivate)
- (void) persistLastActivityDate;
@end

NS_ASSUME_NONNULL_END
