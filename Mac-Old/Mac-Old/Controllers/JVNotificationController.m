#import "JVNotificationController.h"
#import "KABubbleWindowController.h"
#import "KABubbleWindowView.h"
#import "MaddsPathExtensions.h"

#define GrowlApplicationBridge NSClassFromString( @"GrowlApplicationBridge" )

static JVNotificationController *sharedInstance = nil;

@interface JVNotificationController (JVNotificationControllerPrivate) <KABubbleWindowControllerDelegate>
- (void) _bounceIconOnce;
- (void) _bounceIconContinuously;
- (void) _showBubbleForIdentifier:(NSString *) identifier withContext:(NSDictionary *) context andPrefs:(NSDictionary *) eventPrefs;
- (void) _playSound:(NSString *) path;
@end

#pragma mark -

@implementation JVNotificationController
+ (JVNotificationController *) defaultController {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

#pragma mark -

- (instancetype) init {
	if( ( self = [super init] ) ) {
		_bubbles = [[NSMutableDictionary alloc] init];
		_sounds = [[NSMutableDictionary alloc] init];

		[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];

	}

	return self;
}

- (void) dealloc {
	[[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	if( self == sharedInstance ) sharedInstance = nil;

	_bubbles = nil;
	_sounds = nil;
}

- (void) performNotification:(NSString *) identifier withContextInfo:(NSDictionary *) context {
	NSDictionary *eventPrefs = [[NSUserDefaults standardUserDefaults] dictionaryForKey:[NSString stringWithFormat:@"JVNotificationSettings %@", identifier]];

	if( [eventPrefs[@"playSound"] boolValue] && ! [[NSUserDefaults standardUserDefaults] boolForKey:@"JVChatNotificationsMuted"] ) {
		if( [eventPrefs[@"playSoundOnlyIfBackground"] boolValue] && ! [[NSApplication sharedApplication] isActive] )
			[self _playSound:eventPrefs[@"soundPath"]];
		else if( ! [eventPrefs[@"playSoundOnlyIfBackground"] boolValue] )
			[self _playSound:eventPrefs[@"soundPath"]];
	}

	if( [eventPrefs[@"bounceIcon"] boolValue] ) {
		if( [eventPrefs[@"bounceIconUntilFront"] boolValue] )
			[self _bounceIconContinuously];
		else [self _bounceIconOnce];
	}

	if( [eventPrefs[@"showBubble"] boolValue] ) {
		if( [eventPrefs[@"showBubbleOnlyIfBackground"] boolValue] && ! [[NSApplication sharedApplication] isActive] )
			[self _showBubbleForIdentifier:identifier withContext:context andPrefs:eventPrefs];
		else if( ! [eventPrefs[@"showBubbleOnlyIfBackground"] boolValue] )
			[self _showBubbleForIdentifier:identifier withContext:context andPrefs:eventPrefs];
	}

	NSMethodSignature *signature = [NSMethodSignature methodSignatureWithReturnAndArgumentTypes:@encode( void ), @encode( NSString * ), @encode( NSDictionary * ), @encode( NSDictionary * ), nil];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

	[invocation setSelector:@selector( performNotification:withContextInfo:andPreferences: )];
	MVAddUnsafeUnretainedAddress(identifier, 2)
	MVAddUnsafeUnretainedAddress(context, 3)
	MVAddUnsafeUnretainedAddress(eventPrefs, 4)

	[[MVChatPluginManager defaultManager] makePluginsPerformInvocation:invocation];
}

- (void) userNotificationCenter:(NSUserNotificationCenter *) center didActivateNotification:(NSUserNotification *) notification {
	id target = (notification.userInfo)[@"target"];
	SEL action = NSSelectorFromString((notification.userInfo)[@"action"]);

	if ( target && action && [target respondsToSelector:action] )
		[target performSelector:action withObject:nil];
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
	// Always show when asked, because we have our own preference for "only notify when not active".
	return YES;
}

@end

#pragma mark -

@implementation JVNotificationController (JVNotificationControllerPrivate)
- (void) _bounceIconOnce {
	[[NSApplication sharedApplication] requestUserAttention:NSInformationalRequest];
}

- (void) _bounceIconContinuously {
	[[NSApplication sharedApplication] requestUserAttention:NSCriticalRequest];
}

- (void) _showBubbleForIdentifier:(NSString *) identifier withContext:(NSDictionary *) context andPrefs:(NSDictionary *) eventPrefs {
	KABubbleWindowController *bubble = nil;
	NSImage *icon = context[@"image"];
	id title = context[@"title"];
	id description = context[@"description"];

	if( ! icon ) icon = [[NSApplication sharedApplication] applicationIconImage];

	{
		NSUserNotification *notification = [[NSUserNotification alloc] init];
		notification.title = title;

		NSString *notificationSubtitle = context[@"subtitle"];
		if (!notificationSubtitle.length) {
			if ([description isKindOfClass:[NSString class]]) {
				notificationSubtitle = description;
			}
			else if ([description isKindOfClass:[NSAttributedString class]]) {
				notificationSubtitle = [description string];
			}
		}
		notification.subtitle = notificationSubtitle;

		[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	}
}

- (void) bubbleDidFadeOut:(KABubbleWindowController *) bubble {
	NSMutableDictionary *bubbles = [_bubbles copy];
	for( NSString *key in bubbles ) {
		KABubbleWindowController *cBubble = bubbles[key];
		if( cBubble == bubble )
			[_bubbles removeObjectForKey:key];
	}
}

- (void) _playSound:(NSString *) path {
	if( ! path ) return;
	NSString *oldPath = path;

	if( ! [path isAbsolutePath] ) {
		path = [[NSBundle mainBundle] pathForResource:path ofType:nil inDirectory:@"Sounds"];
		if (!path) {
			// fall-back in case the sound file isn't there.
			// so the dictionary doesn't get sent nil.
			path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponents:@[@"Sounds", oldPath]];
		}
	}
	
	oldPath = nil;

	NSSound *sound;
	if( ! (sound = _sounds[path]) ) {
		sound = [[NSSound alloc] initWithContentsOfFile:path byReference:YES];
		_sounds[path] = sound;
	}

	// When run on a laptop using battery power, the play method may block while the audio
	// hardware warms up.  If it blocks, the sound WILL NOT PLAY after the block ends.
	// To get around this, we check to make sure the sound is playing, and if it isn't
	// we call the play method again.

	[sound play];
	if( ! [sound isPlaying] ) [sound play];
}

@end
