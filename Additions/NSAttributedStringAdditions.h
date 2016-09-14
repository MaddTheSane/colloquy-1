#import <Foundation/NSAttributedString.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *NSChatWindowsIRCFormatType;
extern NSString *NSChatCTCPTwoFormatType;

#define JVItalicObliquenessValue 0.16

@interface NSAttributedString (NSAttributedStringHTMLAdditions)
#if !((defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE) || (defined(TARGET_OS_TV) && TARGET_OS_TV)) 
+ (instancetype) attributedStringWithHTMLFragment:(NSString *) fragment;

+ (instancetype) attributedStringWithChatFormat:(NSData *) data options:(NSDictionary<NSString*,id> *) options;
- (instancetype) initWithChatFormat:(NSData *) data options:(NSDictionary<NSString*,id> *) options;
#endif

- (NSString *) HTMLFormatWithOptions:(NSDictionary<NSString*,id> *) options;
- (NSData *) chatFormatWithOptions:(NSDictionary<NSString*,id> *) options;

- (NSAttributedString *) cq_stringByRemovingCharactersInSet:(NSCharacterSet *) set;

- (NSAttributedString *) attributedSubstringFromIndex:(NSUInteger) index;
- (NSArray <NSAttributedString *> *) cq_componentsSeparatedByCharactersInSet:(NSCharacterSet *) characterSet;
- (NSAttributedString *) cq_stringByTrimmingCharactersInSet:(NSCharacterSet *) characterSet;
@end

NS_ASSUME_NONNULL_END
