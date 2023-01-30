#import <Foundation/NSDate.h>
#import <Foundation/NSDateFormatter.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (NSDateAdditions)
+ (NSString *) formattedStringWithDate:(NSDate *) date dateStyle:(NSDateFormatterStyle) dateStyle timeStyle:(NSDateFormatterStyle) timeStyle;
+ (NSString *) formattedStringWithDate:(NSDate *) date dateFormat:(NSString *) format;

+ (NSString *) formattedShortDateStringForDate:(NSDate *) date;
+ (NSString *) formattedShortDateAndTimeStringForDate:(NSDate *) date;
+ (NSString *) formattedShortTimeStringForDate:(NSDate *) date;

@property (readonly, copy) NSString *localizedDescription;
@end

@interface NSString (NSDateAdditions)
- (nullable NSDate *) dateFromFormat:(NSString *) format;
@end

NSString *_Nullable humanReadableTimeInterval(NSTimeInterval interval);

NS_ASSUME_NONNULL_END
