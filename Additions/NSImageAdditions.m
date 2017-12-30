#import "NSImageAdditions.h"

@implementation NSImage (NSImageAdditions)
// Created for Adium by Evan Schoenberg on Tue Dec 02 2003 under the GPL.
// Draw this image in a rect, tiling if the rect is larger than the image
- (void) tileInRect:(NSRect) rect {
	[[NSGraphicsContext currentContext] saveGraphicsState];
	NSColor *aColor = [NSColor colorWithPatternImage:self];
	[aColor set];
	[[NSBezierPath bezierPathWithRect:rect] fill];

	[[NSGraphicsContext currentContext] restoreGraphicsState];
}

// Everything below here was created for Colloquy by Zachary Drayer under the same license as Chat Core
+ (NSImage *) imageFromPDF:(NSString *) pdfName {
	static NSMutableDictionary *images = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		images = [NSMutableDictionary dictionary];
	});

	NSImage *image = images[pdfName];
	if (!image) {
		NSImage *temporaryImage = [NSImage imageNamed:pdfName];
		image = [[NSImage alloc] initWithData:temporaryImage.TIFFRepresentation];

		images[pdfName] = image;
	}

	return image;
}
@end
