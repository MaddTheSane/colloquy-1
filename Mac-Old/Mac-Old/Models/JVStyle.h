#import <Foundation/Foundation.h>
#import "JVChatTranscript.h"

@class JVChatMessage;
@class JVEmoticonSet;

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName const JVStylesScannedNotification;
extern NSNotificationName const JVDefaultStyleChangedNotification;
extern NSNotificationName const JVDefaultStyleVariantChangedNotification;
extern NSNotificationName const JVNewStyleVariantAddedNotification;
extern NSNotificationName const JVStyleVariantChangedNotification;

COLLOQUY_EXPORT
@interface JVStyle : NSObject {
	NSBundle *_bundle;
	NSDictionary<NSString*,id> *_parameters;
	NSArray *_styleOptions;
	NSArray *_variants;
	NSArray *_userVariants;
	struct _xsltStylesheet *_XSLStyle;
}
+ (void) scanForStyles;
@property (class, readonly, copy) NSSet<JVStyle*> *styles;
+ (nullable JVStyle*) styleWithIdentifier:(NSString *) identifier;
+ (nullable JVStyle*) newWithBundle:(NSBundle *) bundle NS_SWIFT_NAME(with(bundle:));

@property (class, strong, null_resettable) JVStyle *defaultStyle;

- (nullable instancetype) initWithBundle:(NSBundle *) bundle;

- (void) unlink;
- (void) reload;
@property (getter=isCompliant, readonly) BOOL compliant;

@property (readonly, strong) NSBundle *bundle;
@property (readonly, copy) NSString *identifier;

- (nullable NSString *) transformChatTranscript:(JVChatTranscript *) transcript withParameters:(NSDictionary<NSString*,id> *) parameters;
- (nullable NSString *) transformChatTranscriptElement:(id <JVChatTranscriptElement>) element withParameters:(NSDictionary<NSString*,id> *) parameters;
- (nullable NSString *) transformChatMessage:(JVChatMessage *) message withParameters:(NSDictionary<NSString*,id> *) parameters;
- (nullable NSString *) transformChatTranscriptElements:(NSArray<id<JVChatTranscriptElement>> *) elements withParameters:(NSDictionary<NSString*,id> *) parameters;
- (nullable NSString *) transformXML:(NSString *) xml withParameters:(NSDictionary<NSString*,id> *) parameters;
- (nullable NSString *) transformXMLDocument:(struct _xmlDoc *) document withParameters:(NSDictionary<NSString*,id> *) parameters;

- (NSComparisonResult) compare:(JVStyle *) style;
@property (readonly, copy) NSString *displayName;

@property (readonly, copy) NSString *mainVariantDisplayName;
@property (readonly, copy) NSArray<NSString*> *variantStyleSheetNames;
@property (readonly, copy) NSArray<NSString*> *userVariantStyleSheetNames;
- (BOOL) isUserVariantName:(NSString *) name;
@property (copy, nonatomic) NSString *defaultVariantName;

@property (strong) JVEmoticonSet *defaultEmoticonSet;

@property (readonly, copy) NSArray<NSDictionary<NSString*,id>*> *styleSheetOptions;

@property (copy) NSDictionary<NSString*,id> *mainParameters;

@property (readonly, copy) NSURL *baseLocation;
@property (readonly, copy) NSURL *mainStyleSheetLocation;
- (nullable NSURL *) variantStyleSheetLocationWithName:(NSString *) name;
- (nullable NSURL *) bodyTemplateLocationWithName:(NSString *) name;
@property (readonly, copy, nullable) NSURL *XMLStyleSheetLocation;
@property (readonly, copy, nullable) NSURL *previewTranscriptLocation;

@property (readonly, copy) NSString *contentsOfMainStyleSheet;
- (NSString *) contentsOfVariantStyleSheetWithName:(NSString *) name;
- (NSString *) contentsOfBodyTemplateWithName:(NSString *) name;
@end

NS_ASSUME_NONNULL_END
