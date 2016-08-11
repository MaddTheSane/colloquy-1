#include <Availability.h>

#import <Foundation/Foundation.h>

#import <ChatCore/MVAvailability.h>
#import <ChatCore/MVUtilities.h>
#import <ChatCore/MVChatString.h>

#import <ChatCore/MVChatConnection.h>
#import <ChatCore/MVChatRoom.h>
#import <ChatCore/MVChatUser.h>
#import <ChatCore/MVChatUserWatchRule.h>
#import <ChatCore/MVFileTransfer.h>
#import <ChatCore/MVDirectChatConnection.h>

#if !(TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV)
#import <ChatCore/MVChatPluginManager.h>
#endif


// Additions
#import <ChatCore/NSStringAdditions.h>
#import <ChatCore/NSNumberAdditions.h>
#import <ChatCore/NSDataAdditions.h>
#import <ChatCore/NSScannerAdditions.h>
#import <ChatCore/NSNotificationAdditions.h>
#import <ChatCore/NSDateAdditions.h>
#import <ChatCore/NSRegularExpressionAdditions.h>

#if !(TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV)
#import <ChatCore/NSAttributedStringAdditions.h>
#import <ChatCore/NSColorAdditions.h>
#import <ChatCore/NSMethodSignatureAdditions.h>
#import <ChatCore/NSScriptCommandAdditions.h>
#endif
