#import <Foundation/Foundation.h>
#import "MVAvailability.h"


NS_ASSUME_NONNULL_BEGIN

@class MVChatUser;

extern NSString *MVDownloadFileTransferOfferNotification;
extern NSString *MVFileTransferDataTransferredNotification;
extern NSString *MVFileTransferStartedNotification;
extern NSString *MVFileTransferFinishedNotification;
extern NSString *MVFileTransferErrorOccurredNotification;

extern NSString *MVFileTransferErrorDomain;

typedef NS_ENUM(OSType, MVFileTransferStatus) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVFileTransfer, Status, _val)
	MVEnumVal(Done, 'trDn'),
	MVEnumVal(Normal, 'trNo'),
	MVEnumVal(Holding, 'trHo'),
	MVEnumVal(Stopped, 'trSt'),
	MVEnumVal(Error, 'trEr'),
#undef MVEnumVal
};

typedef NS_ENUM(NSInteger, MVFileTransferError) {
#define MVEnumVal(_name, _val) _MVEnumVal(_name, \
MVFileTransfer, Error, _val)
	MVEnumVal(Connection, -1),
	MVEnumVal(FileCreation, -2),
	MVEnumVal(FileOpen, -3),
	MVEnumVal(AlreadyExists, -4),
	MVEnumVal(UnexpectedlyEnded, -5),
	MVEnumVal(KeyAgreement, -6)
#undef MVEnumVal
};

static inline NSString *NSStringFromMVFileTransferStatus(MVFileTransferStatus status);
static inline NSString *NSStringFromMVFileTransferStatus(MVFileTransferStatus status) {
	switch(status) {
	case MVFileTransferDoneStatus: return @"trDn";
	case MVFileTransferNormalStatus: return @"trNo";
	case MVFileTransferHoldingStatus: return @"trHo";
	case MVFileTransferStoppedStatus: return @"trSt";
	case MVFileTransferErrorStatus: return @"trEr";
	}
}

@interface MVFileTransfer : NSObject
+ (void) setFileTransferPortRange:(NSRange) range;
+ (NSRange) fileTransferPortRange;

+ (void) setAutoPortMappingEnabled:(BOOL) enable;
+ (BOOL) isAutoPortMappingEnabled;

#if __has_feature(objc_class_property)
@property (class) NSRange fileTransferPortRange;
@property (class, getter=isAutoPortMappingEnabled) BOOL autoPortMappingEnabled;
#endif

- (instancetype) init NS_UNAVAILABLE;
- (instancetype) initWithUser:(MVChatUser *) user NS_DESIGNATED_INITIALIZER;

@property(readonly, getter=isUpload) BOOL upload;
@property(readonly, getter=isDownload) BOOL download;
@property(readonly, getter=isPassive) BOOL passive;
@property(readonly) MVFileTransferStatus status;
@property(strong, readonly) NSError *lastError;

@property(readonly) unsigned long long finalSize;
@property(readonly) unsigned long long transferred;

@property(strong, readonly) NSDate *startDate;
@property(readonly) unsigned long long startOffset;

@property(strong, readonly) NSString *host;
@property(readonly) unsigned short port;

@property(strong, readonly) MVChatUser *user;

- (void) cancel;
@end

#pragma mark -

@interface MVUploadFileTransfer : MVFileTransfer {
@protected
	NSString *_source;
}
+ (nullable instancetype) transferWithSourceFile:(NSString *) path toUser:(MVChatUser *) user passively:(BOOL) passive;

@property(strong, readonly) NSString *source;
@end

#pragma mark -

@interface MVDownloadFileTransfer : MVFileTransfer {
@protected
	BOOL _rename;
	NSString *_destination;
	NSString *_originalFileName;
}
@property(copy) NSString *destination;
@property(strong, readonly) NSString *originalFileName;

- (void) setDestination:(NSString *) path renameIfFileExists:(BOOL) allow;

- (void) reject;

- (void) accept;
- (void) acceptByResumingIfPossible:(BOOL) resume;
@end

NS_ASSUME_NONNULL_END
