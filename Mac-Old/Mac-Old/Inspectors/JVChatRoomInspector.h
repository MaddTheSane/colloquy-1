#import <Cocoa/Cocoa.h>

#import "JVChatRoomPanel.h"
#import "JVInspectorController.h"


@interface JVChatRoomPanel (JVChatRoomInspection) <JVInspection>
@property (readonly, strong) id<JVInspector> inspector;
@end

@interface JVChatRoomInspector : NSObject <JVInspector> {
	IBOutlet NSView *view;
	IBOutlet NSTextField *nameField;
	IBOutlet NSTextField *infoField;
	IBOutlet NSPopUpButton *encodingSelection;
	IBOutlet NSPopUpButton *styleSelection;
	IBOutlet NSPopUpButton *emoticonSelection;
	IBOutlet NSButton *privateRoom;
	IBOutlet NSButton *secretRoom;
	IBOutlet NSButton *inviteOnly;
	IBOutlet NSButton *noOutside;
	IBOutlet NSButton *moderated;
	IBOutlet NSButton *topicChangeable;
	IBOutlet NSButton *limitMembers;
	IBOutlet NSTextField *memberLimit;
	IBOutlet NSButton *requiresPassword;
	IBOutlet NSTextField *password;
	IBOutlet NSTextView *topic;
	IBOutlet NSButton *saveTopic;
	IBOutlet NSButton *resetTopic;
	IBOutlet NSTableView *banRules;
	IBOutlet NSButton *newBanButton;
	IBOutlet NSButton *deleteBanButton;
	IBOutlet NSButton *editBanButton;
	JVChatRoomPanel *_room;
	NSMutableArray *_latestBanList;
	BOOL _nibLoaded;
}
- (instancetype) initWithRoom:(JVChatRoomPanel *) room;

- (IBAction) changeChatOption:(id) sender;
- (IBAction) refreshBanList:(id) sender;

- (IBAction) saveTopic:(id) sender;
- (IBAction) resetTopic:(id) sender;

- (IBAction) newBanRule:(id) sender;
- (IBAction) deleteBanRule:(id) sender;
- (IBAction) editBanRule:(id) sender;
@end
