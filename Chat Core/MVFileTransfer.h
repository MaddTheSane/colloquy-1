#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@class MVChatUser;

COLLOQUY_EXPORT extern NSNotificationName MVDownloadFileTransferOfferNotification;
COLLOQUY_EXPORT extern NSNotificationName MVFileTransferDataTransferredNotification;
COLLOQUY_EXPORT extern NSNotificationName MVFileTransferStartedNotification;
COLLOQUY_EXPORT extern NSNotificationName MVFileTransferFinishedNotification;
COLLOQUY_EXPORT extern NSNotificationName MVFileTransferErrorOccurredNotification;

COLLOQUY_EXPORT extern NSErrorDomain MVFileTransferErrorDomain;

typedef NS_ENUM(OSType, MVFileTransferStatus) {
	MVFileTransferDoneStatus NS_SWIFT_NAME(done) = 'trDn',
	MVFileTransferNormalStatus NS_SWIFT_NAME(normal) = 'trNo',
	MVFileTransferHoldingStatus NS_SWIFT_NAME(holding) = 'trHo',
	MVFileTransferStoppedStatus NS_SWIFT_NAME(stopped) = 'trSt',
	MVFileTransferErrorStatus NS_SWIFT_NAME(error) = 'trEr'
};

typedef NS_ERROR_ENUM(MVFileTransferErrorDomain, MVFileTransferError) {
	MVFileTransferConnectionError NS_SWIFT_NAME(connection) = -1,
	MVFileTransferFileCreationError NS_SWIFT_NAME(fileCreation) = -2,
	MVFileTransferFileOpenError NS_SWIFT_NAME(foleOpen) = -3,
	MVFileTransferAlreadyExistsError NS_SWIFT_NAME(alreadyExists) = -4,
	MVFileTransferUnexpectedlyEndedError NS_SWIFT_NAME(unexpectedlyEnded) = -5,
	MVFileTransferKeyAgreementError NS_SWIFT_NAME(keyAgreement) = -6
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

COLLOQUY_EXPORT
@interface MVFileTransfer : NSObject

@property (class) NSRange fileTransferPortRange;

@property (class, getter=isAutoPortMappingEnabled) BOOL autoPortMappingEnabled;

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

COLLOQUY_EXPORT
@interface MVUploadFileTransfer : MVFileTransfer {
@protected
	NSString *_source;
}
+ (nullable instancetype) transferWithSourceFile:(NSString *) path toUser:(MVChatUser *) user passively:(BOOL) passive;

@property(strong, readonly) NSString *source;
@end

#pragma mark -

COLLOQUY_EXPORT
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
