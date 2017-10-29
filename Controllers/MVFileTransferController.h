#import <Cocoa/Cocoa.h>

NSString *MVPrettyFileSize( unsigned long long size );
NSString *MVReadableTime( NSTimeInterval date, BOOL longFormat );

@class MVFileTransfer;

COLLOQUY_EXPORT
@interface MVFileTransferController : NSWindowController <NSOpenSavePanelDelegate, NSToolbarDelegate, NSURLDownloadDelegate> {
@private
	IBOutlet NSProgressIndicator *progressBar;
	IBOutlet NSTextField *transferStatus;
	IBOutlet NSTableView *currentFiles;
	NSMutableArray *_transferStorage;
	NSMutableArray *_calculationItems;
	NSTimer *_updateTimer;
	NSSet *_safeFileExtentions;
}

@property (copy, class) NSString *userPreferredDownloadFolder;

@property (readonly, strong, class) MVFileTransferController *defaultController;

- (IBAction) showTransferManager:(id) sender;
- (IBAction) hideTransferManager:(id) sender;

- (void) downloadFileAtURL:(NSURL *) url toLocalFile:(NSString *) path;
- (void) addFileTransfer:(MVFileTransfer *) transfer;

- (IBAction) stopSelectedTransfer:(id) sender;
- (IBAction) clearFinishedTransfers:(id) sender;
- (IBAction) revealSelectedFile:(id) sender;
@end
