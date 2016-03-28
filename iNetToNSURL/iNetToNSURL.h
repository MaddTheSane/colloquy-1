//
//  iNetToNSURL.h
//  iNetToNSURL
//
//  Created by C.W. Betts on 3/28/16.
//
//

#import <Foundation/Foundation.h>
#import "iNetToNSURLProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface iNetToNSURL : NSObject <iNetToNSURLProtocol>
@end
