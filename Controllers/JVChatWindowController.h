#import "JVInspectorController.h"

@class MVMenuButton;
@class MVChatConnection;
@class JVChatWindowController;

@protocol JVChatViewController;
@protocol JVChatListItem;

NS_ASSUME_NONNULL_BEGIN

extern NSString *JVToolbarToggleChatDrawerItemIdentifier;
extern NSString *JVChatViewPboardType;

@interface JVChatWindowController : NSWindowController <JVInspectionDelegator, NSMenuDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSToolbarDelegate, NSWindowDelegate> {
	@protected
	IBOutlet NSDrawer *viewsDrawer;
	IBOutlet NSOutlineView *chatViewsOutlineView;
	IBOutlet MVMenuButton *viewActionButton;
	IBOutlet MVMenuButton *favoritesButton;
	NSString *_identifier;
	NSMutableDictionary *_settings;
	NSMutableArray/*<id <JVChatViewController>>*/ *_views;
	id <JVChatViewController> _activeViewController;
	BOOL _usesSmallIcons;
	BOOL _showDelayed;
	BOOL _reloadingData;
	BOOL _closing;
}
@property (copy) NSString *identifier;

@property (readonly, copy) NSString *userDefaultsPreferencesKey;
- (void) setPreference:(id _Nullable) value forKey:(NSString *) key;
- (id _Nullable) preferenceForKey:(NSString *) key;

- (void) showChatViewController:(id <JVChatViewController>) controller;

- (void) addChatViewController:(id <JVChatViewController>) controller;
- (void) insertChatViewController:(id <JVChatViewController>) controller atIndex:(NSUInteger) index;

- (void) removeChatViewController:(id <JVChatViewController>) controller;
- (void) removeChatViewControllerAtIndex:(NSUInteger) index;
- (void) removeAllChatViewControllers;

- (void) replaceChatViewController:(id <JVChatViewController>) controller withController:(id <JVChatViewController>) newController;
- (void) replaceChatViewControllerAtIndex:(NSUInteger) index withController:(id <JVChatViewController>) controller;

- (NSArray<id<JVChatViewController>> *) chatViewControllersForConnection:(MVChatConnection *) connection;
- (NSArray<id<JVChatViewController>> *) chatViewControllersWithControllerClass:(Class) class;
- (NSArray<id<JVChatViewController>> *) allChatViewControllers;

- (id <JVChatViewController>) activeChatViewController;
- (id <JVChatListItem>) selectedListItem;

- (IBAction) getInfo:(id _Nullable) sender;

- (IBAction) joinRoom:(id _Nullable) sender;

- (IBAction) closeCurrentPanel:(id _Nullable) sender;
- (IBAction) detachCurrentPanel:(id _Nullable) sender;
- (IBAction) selectPreviousPanel:(id _Nullable) sender;
- (IBAction) selectPreviousActivePanel:(id _Nullable) sender;
- (IBAction) selectNextPanel:(id _Nullable) sender;
- (IBAction) selectNextActivePanel:(id _Nullable) sender;

- (NSToolbarItem *) toggleChatDrawerToolbarItem;
- (IBAction) toggleViewsDrawer:(id _Nullable) sender;
- (IBAction) openViewsDrawer:(id _Nullable) sender;
- (IBAction) closeViewsDrawer:(id _Nullable) sender;
- (IBAction) toggleSmallDrawerIcons:(id _Nullable) sender;

- (void) reloadListItem:(id <JVChatListItem>) controller andChildren:(BOOL) children;
- (BOOL) isListItemExpanded:(id <JVChatListItem>) item;
- (void) expandListItem:(id <JVChatListItem>) item;
- (void) collapseListItem:(id <JVChatListItem>) item;
@end

@interface JVChatWindowController (Private)
- (void) _claimMenuCommands;
- (void) _resignMenuCommands;
- (void) _doubleClickedListItem:(id) sender;
- (void) _deferRefreshSelectionMenu;
- (void) _refreshSelectionMenu;
- (void) _refreshMenuWithItem:(id) item;
- (void) _refreshWindow;
- (void) _refreshToolbar;
- (void) _refreshWindowTitle;
- (void) _refreshList;
- (void) _refreshPreferences;
- (void) _saveWindowFrame;
- (void) _switchViews:(id) sender;
- (void) _favoritesListDidUpdate:(NSNotification *) notification;
@end

@interface JVChatWindowController (JVChatWindowControllerScripting)
- (NSNumber *) uniqueIdentifier;
@end

@protocol JVChatViewController <JVChatListItem>
@optional
- (id <JVChatViewController>) activeChatViewController;

@required
- (MVChatConnection * _Nullable) connection;

- (JVChatWindowController * _Nullable) windowController;
- (void) setWindowController:(JVChatWindowController * _Nullable) controller;

- (NSView *) view;
- (NSResponder * _Nullable) firstResponder;
- (NSString *) toolbarIdentifier;
- (NSString *) windowTitle;
- (NSString *) identifier;
@end

@interface NSObject (JVChatViewControllerOptional)
- (void) willSelect;
- (void) didSelect;

- (void) willUnselect;
- (void) didUnselect;

- (void) willDispose;
@end

@protocol JVChatListItemScripting <NSObject>
- (NSNumber *) uniqueIdentifier;
- (NSArray * _Nullable) children;
- (NSString * _Nullable) information;
- (NSString *) toolTip;
- (BOOL) isEnabled;
@end

@protocol JVChatViewControllerScripting <JVChatListItemScripting>
- (NSWindow *) window;
- (IBAction) close:(id _Nullable) sender;
@end

@protocol JVChatListItem <NSObject>
- (id <JVChatListItem>) parent;
- (NSImage *) icon;
- (NSString *) title;
@end

@interface NSObject (JVChatListItemOptional)
- (BOOL) acceptsDraggedFileOfType:(NSString *) type;
- (void) handleDraggedFile:(NSString *) path;
- (IBAction) doubleClicked:(id _Nullable) sender;
- (BOOL) isEnabled;

- (NSMenu *) menu;
- (NSString * _Nullable) information;
- (NSString *) toolTip;
- (NSImage * _Nullable) statusImage;

- (NSUInteger) numberOfChildren;
- (id) childAtIndex:(NSUInteger) index;
@end

@interface NSObject (MVChatPluginToolbarSupport)
- (NSArray <NSString*>* _Nullable) toolbarItemIdentifiersForView:(id <JVChatViewController>) view;
- (NSToolbarItem * _Nullable) toolbarItemForIdentifier:(NSString *) identifier inView:(id <JVChatViewController>) view willBeInsertedIntoToolbar:(BOOL) willBeInserted;
@end

NS_ASSUME_NONNULL_END
