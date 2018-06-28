#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MVTextViewDelegate;

@interface MVTextView : NSTextView {
    NSDictionary *defaultTypingAttributes;
	NSSize lastPostedSize;
	NSSize _desiredSizeCached;
	BOOL _tabCompletting;
	BOOL _ignoreSelectionChanges;
	BOOL _complettingWithSuffix;
	NSString *_lastCompletionMatch;
	NSString *_lastCompletionPrefix;
}
- (BOOL) checkKeyEvent:(NSEvent *) event;

- (void) setBaseFont:(nullable NSFont *) font;

- (IBAction) reset:(nullable id) sender;

@property (readonly) NSSize minimumSizeForContent;

- (IBAction) bold:(nullable id) sender;
- (IBAction) italic:(nullable id) sender;

@property BOOL usesSystemCompleteOnTab;

- (BOOL) autocompleteWithSuffix:(BOOL) suffix;

@property (atomic, weak, nullable) id <MVTextViewDelegate>delegate;
@end

@protocol MVTextViewDelegate <NSTextViewDelegate>
@optional
- (BOOL) textView:(NSTextView *) textView functionKeyPressed:(NSEvent *) event;
- (BOOL) textView:(NSTextView *) textView enterKeyPressed:(NSEvent *) event;
- (BOOL) textView:(NSTextView *) textView returnKeyPressed:(NSEvent *) event;
- (BOOL) textView:(NSTextView *) textView escapeKeyPressed:(NSEvent *) event;
- (NSArray<NSString*> *) textView:(NSTextView *) textView stringCompletionsForPrefix:(NSString *) prefix;
- (void) textView:(NSTextView *) textView selectedCompletion:(NSString *) completion fromPrefix:(NSString *) prefix;
@end

NS_ASSUME_NONNULL_END
