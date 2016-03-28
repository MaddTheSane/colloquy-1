//
//  iNetToNSURL.m
//  iNetToNSURL
//
//  Created by C.W. Betts on 3/28/16.
//
//

#import "iNetToNSURL.h"
#import "NSURLAdditions.h"

@implementation iNetToNSURL

// This implements the example protocol. Replace the body of this class with the implementation of this service's protocol.
- (void)carbonURLResourceAtPathToURL:(NSString *)aString withReply:(void (^)(NSURL *))reply {
	NSURL *response = [NSURL URLWithInternetLocationFile:aString];
    reply(response);
}

@end
