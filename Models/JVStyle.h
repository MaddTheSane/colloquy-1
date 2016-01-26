#import "JVChatTranscript.h"

@class JVChatMessage;
@class JVEmoticonSet;

NS_ASSUME_NONNULL_BEGIN

extern NSString *JVStylesScannedNotification;
extern NSString *JVDefaultStyleChangedNotification;
extern NSString *JVDefaultStyleVariantChangedNotification;
extern NSString *JVNewStyleVariantAddedNotification;
extern NSString *JVStyleVariantChangedNotification;

@interface JVStyle : NSObject {
	NSBundle *_bundle;
	NSDictionary *_parameters;
	NSArray *_styleOptions;
	NSArray *_variants;
	NSArray *_userVariants;
	struct _xsltStylesheet *_XSLStyle;
}
+ (void) scanForStyles;
+ (NSSet<JVStyle*> *) styles;
+ (nullable instancetype) styleWithIdentifier:(NSString *) identifier;
+ (nullable instancetype) newWithBundle:(NSBundle *) bundle;

+ (JVStyle*) defaultStyle;
+ (void) setDefaultStyle:(nullable JVStyle *) style;

- (nullable instancetype) initWithBundle:(NSBundle *) bundle;

- (void) unlink;
- (void) reload;
@property (getter=isCompliant, readonly) BOOL compliant;

@property (readonly, strong) NSBundle *bundle;
@property (readonly, copy) NSString *identifier;

- (nullable NSString *) transformChatTranscript:(JVChatTranscript *) transcript withParameters:(NSDictionary *) parameters;
- (nullable NSString *) transformChatTranscriptElement:(id <JVChatTranscriptElement>) element withParameters:(NSDictionary *) parameters;
- (nullable NSString *) transformChatMessage:(JVChatMessage *) message withParameters:(NSDictionary *) parameters;
- (nullable NSString *) transformChatTranscriptElements:(NSArray *) elements withParameters:(NSDictionary *) parameters;
- (nullable NSString *) transformXML:(NSString *) xml withParameters:(NSDictionary *) parameters;
- (nullable NSString *) transformXMLDocument:(struct _xmlDoc *) document withParameters:(NSDictionary *) parameters;

- (NSComparisonResult) compare:(JVStyle *) style;
@property (readonly, copy) NSString *displayName;

@property (readonly, copy) NSString *mainVariantDisplayName;
@property (readonly, copy) NSArray *variantStyleSheetNames;
@property (readonly, copy) NSArray *userVariantStyleSheetNames;
- (BOOL) isUserVariantName:(NSString *) name;
@property (copy, nonatomic) NSString *defaultVariantName;

@property (strong) JVEmoticonSet *defaultEmoticonSet;

@property (readonly, copy) NSArray *styleSheetOptions;

@property (copy) NSDictionary *mainParameters;

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
