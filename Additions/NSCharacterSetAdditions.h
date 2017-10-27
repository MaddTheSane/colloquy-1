NS_ASSUME_NONNULL_BEGIN

@interface NSCharacterSet (Additions)
@property (class, readonly, strong) NSCharacterSet *illegalXMLCharacterSet;
@property (class, readonly, strong, getter=cq_encodedXMLCharacterSet) NSCharacterSet *encodedXMLCharacterSet;
@end

NS_ASSUME_NONNULL_END
