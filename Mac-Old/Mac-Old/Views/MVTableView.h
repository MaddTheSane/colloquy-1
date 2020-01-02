#import <Cocoa/Cocoa.h>

@class MVTableView;

@protocol MVTableViewDataSource <NSTableViewDataSource>
- (NSMenu *) tableView:(MVTableView *) view menuForTableColumn:(NSTableColumn *) column row:(NSInteger) row;
- (NSString *) tableView:(MVTableView *) view toolTipForTableColumn:(NSTableColumn *) column row:(NSInteger) row;
@end

@protocol MVTableViewDelegate <NSTableViewDelegate>
- (IBAction) clear:(id) sender;
- (NSRect) tableView:(MVTableView *) tableView rectOfRow:(NSInteger) row defaultRect:(NSRect) defaultRect;
- (NSRange) tableView:(MVTableView *) tableView rowsInRect:(NSRect) rect defaultRange:(NSRange) defaultRange;
@end

@interface MVTableView : NSTableView {
	NSUInteger autosaveTableColumnHighlight:1;
	NSUInteger dataSourceDragImageForRows:1;
	NSUInteger dataSourceMenuForTableColumn:1;
	NSUInteger dataSourceToolTipForTableColumn:1;
	NSUInteger delegateRectOfRow:1;
	NSUInteger delegateRowsInRect:1;
}

@property (atomic, weak) id <MVTableViewDataSource> dataSource;
@property (atomic, weak) id <MVTableViewDelegate> delegate;

@property BOOL autosaveTableColumnHighlight;

- (NSRect) originalRectOfRow:(NSInteger) row;
@end
