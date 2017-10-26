NS_ASSUME_NONNULL_BEGIN

#if SYSTEM(MAC)
@interface NSColor (NSColorAdditions)
+ (nullable NSColor *) colorWithHTMLAttributeValue:(NSString *) attribute;
+ (nullable NSColor *) colorWithCSSAttributeValue:(NSString *) attribute;
@property (readonly, copy) NSString *HTMLAttributeValue;
@property (readonly, copy) NSString *CSSAttributeValue;
@end
#endif

NS_ASSUME_NONNULL_END
