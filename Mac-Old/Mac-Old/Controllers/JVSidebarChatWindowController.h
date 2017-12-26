#import "JVChatWindowController.h"
#import "AICustomTabsView.h"

@class JVSideSplitView;

@interface JVSidebarChatWindowController : JVChatWindowController {
	IBOutlet JVSideSplitView *mainSplitView;
	IBOutlet NSImageView *additionalDividerHandle;
	IBOutlet NSView *bodyView;
	IBOutlet NSView *sideView;
	BOOL _forceSplitViewPosition;
}
@end
