#import "MVCrashCatcher.h"
#import <sys/sysctl.h>

@interface MVCrashCatcher ()

@property (atomic, copy) dispatch_block_t doneBlock;

@end

@implementation MVCrashCatcher
+ (void) check {
	static MVCrashCatcher *crashCatcher = nil;
	crashCatcher = [[MVCrashCatcher alloc] init]; // Released when the window is closed.
	crashCatcher.doneBlock = ^{
		crashCatcher.doneBlock = nil;
		crashCatcher = nil;
	};
}

#pragma mark -

- (instancetype) init {
	if (!(self = [super init]))
		return nil;

	NSString *programName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	NSString *logDirectory = [@"~/Library/Logs/DiagnosticReports/" stringByExpandingTildeInPath]; // files in CrashReporter/ are really symlinks to files in this dir in 10.6+

	// If there are multiple crash reports, only get the latest one. Also deletes older crash reports; we don't want to show the error on n launches for an unknown number of n
	for( NSString *file in [[NSFileManager defaultManager] contentsOfDirectoryAtPath:logDirectory error:nil] ) {
		if( [file hasCaseInsensitivePrefix:programName] ) {
			[[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
			logPath = [logDirectory stringByAppendingPathComponent:file];
		}
	}

	if( logPath.length ) [[NSBundle mainBundle] loadNibNamed:@"MVCrashCatcher" owner:self topLevelObjects:NULL];
	else return nil;

	return self;
}

- (void) dealloc {
	[window close];

	if (self.doneBlock)
		self.doneBlock();
}

- (void) awakeFromNib {
	NSString *logContent = [NSString stringWithContentsOfFile:logPath encoding:NSUTF8StringEncoding error:NULL];
	logContent = [logContent stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

	NSString *programName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
	description.stringValue = [NSString stringWithFormat:NSLocalizedString( @"%@ encountered an unrecoverable error during a previous session. Please enter any details you may recall about what you were doing when the application crashed. This will help us to improve future releases of %@.", "crash message" ), programName, programName];
	log.string = logContent;

	[window center];

	[[NSApplication sharedApplication] runModalForWindow:window];
}

#pragma mark -

- (void) connectionDidFinishLoading:(NSURLConnection *) connection {
	[[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];
	self.doneBlock();
}

- (void) connection:(NSURLConnection *) connection didFailWithError:(NSError *) error {
	self.doneBlock();
}

#pragma mark -

- (IBAction) sendCrashLog:(id) sender {
	NSMutableString *body = [NSMutableString stringWithCapacity:40960];

	NSDictionary *systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/ServerVersion.plist"];
	if( ! systemVersion.count ) systemVersion = [NSDictionary dictionaryWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];

	NSDictionary *clientVersion = [NSBundle mainBundle].infoDictionary;

	[body appendFormat:@"app_version=%@%%20(%@)&", [clientVersion[@"CFBundleShortVersionString"] stringByEncodingIllegalURLCharacters], [clientVersion[@"CFBundleVersion"] stringByEncodingIllegalURLCharacters]];
	[body appendFormat:@"os_version=%@:%@&", [systemVersion[@"ProductUserVisibleVersion"] stringByEncodingIllegalURLCharacters], [systemVersion[@"ProductBuildVersion"] stringByEncodingIllegalURLCharacters]];

	int selector[2] = { CTL_HW, HW_MODEL };
	char model[64] = "";
	size_t length = sizeof( model );
	sysctl( selector, 2, &model, &length, NULL, 0 );

	selector[0] = CTL_HW;
	selector[1] = HW_MEMSIZE;
	uint64_t memory = 0;
	length = sizeof( memory );
	sysctl( selector, 2, &memory, &length, NULL, 0 );

	[body appendFormat:@"machine_config=%s%%20(%d%%20MB)&", model, (int) ( memory / (uint64_t) 1024 / (uint64_t) 1024 )];
	[body appendFormat:@"feedback_comments=%@&", [[comments.string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] stringByEncodingIllegalURLCharacters]];

	NSData *trace = [[log string] dataUsingEncoding:NSUTF8StringEncoding];
	[body appendFormat:@"page_source=%@", ( trace ? [trace colBase64Encoding] : @"" )];

	NSURL *url = [NSURL URLWithString:@"http://colloquy.info/crash.php"];
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.];
	request.HTTPMethod = @"POST";
	[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-type"];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES]];

	[NSURLConnection connectionWithRequest:request delegate:self];

	[[NSApplication sharedApplication] stopModal];
	[window orderOut:nil];
}

- (IBAction) dontSend:(id) sender {
	[[NSFileManager defaultManager] removeItemAtPath:logPath error:nil];

	[[NSApplication sharedApplication] stopModal];
	[window orderOut:nil];

	if (self.doneBlock) {
		self.doneBlock();
	}
	self.doneBlock = nil;
}

- (BOOL) windowShouldClose:(id) sender {
	[self dontSend:nil];
	return NO;
}
@end
