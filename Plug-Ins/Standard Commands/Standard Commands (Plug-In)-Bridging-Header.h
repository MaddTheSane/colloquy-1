//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import "Basic.pch"
#import "JVChatController.h"
#import "MVConnectionsController.h"
#import "MVChatUserAdditions.h"
#import "JVDirectChatPanel.h"
#import "JVChatRoomPanel.h"
#import "JVChatMessage.h"
#import "JVInspectorController.h"
#import "JVChatUserInspector.h"
#import "JVChatRoomBrowser.h"
#import "JVStyle.h"
#import "JVEmoticonSet.h"
#import "JVStyleView.h"
#import "JVConnectionInspector.h"

@interface MVChatConnection (MVChatConnectionPrivate)
@property (readonly, copy) NSCharacterSet *_nicknamePrefixes;
@end

