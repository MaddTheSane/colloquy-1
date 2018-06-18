// Created by Mike Shields on 10/9/05.

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

COLLOQUY_EXPORT
@interface JVSpeechController : NSObject <NSSpeechSynthesizerDelegate>
@property (readonly, strong, class) JVSpeechController *sharedSpeechController;
- (void) startSpeakingString:(NSString *) string usingVoice:(NSSpeechSynthesizerVoiceName) voice;
@end

NS_ASSUME_NONNULL_END
