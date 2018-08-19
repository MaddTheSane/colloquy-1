#import <Cocoa/Cocoa.h>

@interface JVSplitView : NSSplitView {
	long _mainSubviewIndex;
}
@property (readonly, copy) NSString *stringWithSavedPosition;
- (void) setPositionFromString:(NSString *) string;

- (void) savePositionUsingName:(NSString *) name;
- (BOOL) setPositionUsingName:(NSString *) name;

@property long mainSubviewIndex;
@end
