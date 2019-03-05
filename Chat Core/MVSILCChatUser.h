#import "MVChatUser.h"
#import "MVChatUserPrivate.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wstrict-prototypes"
#include <libsilcclient/client.h>
#include <libsilc/silcincludes.h>
#pragma clang diagnostic pop

NS_ASSUME_NONNULL_BEGIN

@class MVSILCChatConnection;

@interface MVSILCChatUser : MVChatUser {
	SilcClientEntry _clientEntry;
	BOOL _releasing;
}
- (instancetype) initLocalUserWithConnection:(MVSILCChatConnection *) connection;
- (instancetype) initWithClientEntry:(SilcClientEntry) clientEntry andConnection:(MVSILCChatConnection *) connection;
- (void) updateWithClientEntry:(SilcClientEntry) clientEntry;

- (SilcClientEntry) _getClientEntry;
@property (readonly, getter=_getClientEntry) SilcClientEntry clientEntry;
@end

NS_ASSUME_NONNULL_END
