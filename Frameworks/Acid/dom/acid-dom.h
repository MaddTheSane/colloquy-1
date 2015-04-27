//============================================================================
// 
//     License:
// 
//     This library is free software; you can redistribute it and/or
//     modify it under the terms of the GNU Lesser General Public
//     License as published by the Free Software Foundation; either
//     version 2.1 of the License, or (at your option) any later version.
// 
//     This library is distributed in the hope that it will be useful,
//     but WITHOUT ANY WARRANTY; without even the implied warranty of
//     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//     Lesser General Public License for more details.
// 
//     You should have received a copy of the GNU Lesser General Public
//     License along with this library; if not, write to the Free Software
//     Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  
//     USA
// 
//     Copyright (C) 2002 Dave Smith (dizzyd@jabber.org)
// 
// $Id: acid-dom.h,v 1.2 2004/10/16 21:09:47 alangh Exp $
//============================================================================

#import <Foundation/NSObject.h>

@interface XMLQName : NSObject <NSCopying>

-(instancetype) initWithName:(NSString*)name inURI:(NSString*)uri;

@property (readonly, copy) NSString *name;
@property (readonly, copy) NSString *uri;

-(BOOL) isEqual:(XMLQName*)other;
-(NSComparisonResult) compare:(id)other;

+(XMLQName*) construct:(NSString*)name withURI:(NSString*)uri;
+(XMLQName*) construct:(const char*)name;
+(XMLQName*) construct:(const char*)expatname withDefaultURI:(NSString*)uri;
@end

#define QNAME(uri, elem) [XMLQName construct:elem withURI:uri]

@class XMLAccumulator;

@protocol XMLNode <NSObject>
@property (nonatomic, readonly, retain) XMLQName *qname;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *uri;
-(void)      description:(XMLAccumulator*)acc;
@end



@interface XMLCData : NSObject <XMLNode>

// Basic initializers
-(instancetype)   init;

// Custom initializers
-(instancetype) initWithString:(NSString*)s; // Assumes unescaped data
-(instancetype) initWithCharPtr:(const char*)cptr ofLength:(NSUInteger)clen; // Assumes unescaped data
-(instancetype) initWithEscapedCharPtr:(const char*)cptr ofLength:(NSUInteger)clen;

// Modify text using data that is _not_ escaped
-(void) setText:(const char*)text ofLength:(NSUInteger)textlen;
-(void) setText:(NSString*)text;
-(void) appendText:(const char*)text ofLength:(NSUInteger)textlen;
-(void) appendText:(NSString*)text;

// Modify text using data that is escaped
-(void) setEscapedText:(const char*)text ofLength:(NSUInteger)textlen;
-(void) appendEscapedText:(const char*)text ofLength:(NSUInteger)textlen;

@property (readonly, copy) NSString *text; // Unescaped text

@property (readonly, copy) NSString *description; // Escaped text

// Escaping routines
+(NSString*) escape:(const char*)data ofLength:(NSInteger)datasz;
+(NSString*) escape:(NSString*)data;
+(NSMutableString*) unescape:(const char*)data ofLength:(NSInteger)datasz;

@end


@interface XMLElement : NSObject <XMLNode, NSFastEnumeration>

// Basic initializers
-(instancetype)   init;

// Extended initializers
-(instancetype) initWithQName:(XMLQName*)qname
               withAttributes:(NSMutableDictionary*)atts
               withDefaultURI:(NSString*)uri;

-(instancetype) initWithQName:(XMLQName*)qname;

-(instancetype) initWithQName:(XMLQName*)qname withDefaultURI:(NSString*)uri;

// High-level child initializers
-(XMLElement*) addElement:(XMLElement*)element;
-(XMLElement*) addElementWithName:(NSString*)name;
-(XMLElement*) addElementWithQName:(XMLQName*)name;
-(XMLElement*) addElementWithName:(NSString*)name withDefaultURI:(NSString*)uri;
-(XMLElement*) addElementWithQName:(XMLQName*)name withDefaultURI:(NSString*)uri;

-(XMLCData*)   addCData:(const char*)cdata ofLength:(NSUInteger)cdatasz;
-(XMLCData*)   addCData:(NSString*)cdata;

// Enumerators
@property (readonly, strong) NSEnumerator *childElementsEnumerator;

// Raw child management
@property (readonly, unsafe_unretained) id<XMLNode> firstChild;
-(void) appendChildNode:(id <XMLNode>)node;
-(void) detachChildNode:(id <XMLNode>)node;

// Child node info
@property (readonly) BOOL hasChildren;
@property (readonly) NSUInteger childCount;

// Namespace declaration management
-(void) addNamespaceURI:(NSString*)uri withPrefix:(NSString*)prefix;
-(void) delNamespaceURI:(NSString*)uri;

// Attribute management
-(void)      putAttribute:(NSString*)name withValue:(NSString*)value;
-(NSString*) getAttribute:(NSString*)name;
-(void)      delAttribute:(NSString*)name;
-(BOOL)      cmpAttribute:(NSString*)name withValue:(NSString*)value;

-(void)      putQualifiedAttribute:(XMLQName*)qname withValue:(NSString*)value;
-(NSString*) getQualifiedAttribute:(XMLQName*)qname;
-(void)      delQualifiedAttribute:(XMLQName*)qname;
-(BOOL)      cmpQualifiedAttribute:(XMLQName*)qname withValue:(NSString*)value;


// Convert this node to string representation
@property (readonly, copy) NSString *description;

// Extract first child CDATA from this Element
@property (readonly, copy) NSString *cdata;

// Convert a name and uri into a XMLQName structure
-(XMLQName*) getQName:(NSString*)name ofURI:(NSString*)uri;
-(XMLQName*) getQName:(const char*)expatname;

@property (weak) XMLElement *parent;
@property (readonly, copy) NSString*   defaultURI;

-(NSString*) addUniqueIDAttribute;

-(void) setup;

/// Implemented by subclasses
+(instancetype) constructElement:(XMLQName*)qname withAttributes:(NSMutableDictionary*)atts withDefaultURI:(NSString*)default_uri NS_RETURNS_RETAINED;

@end


@interface XMLAccumulator : NSObject

-(instancetype) init:(NSMutableString*)data;

-(void) addOverridePrefix:(NSString*)prefix forURI:(NSString*)uri;
-(NSString*) generatePrefix:(NSString*)uri;

-(void) openElement:(XMLElement*)elem;
-(void) selfCloseElement;
-(void) closeElement:(XMLElement*)elem;
-(void) addAttribute:(XMLQName*)qname withValue:(NSString*)value ofElement:(XMLElement*)elem;
-(void) addChildren:(NSArray*)children ofElement:(XMLElement*)elem;
-(void) addCData:(XMLCData*)cdata;

+(NSString*) process:(XMLElement*)element;

@end

@protocol XMLElementStreamListener <NSObject>
-(void) onDocumentStart:(XMLElement*)element;
-(void) onElement:(XMLElement*)element;
-(void) onCData:(XMLCData*)cdata;
-(void) onDocumentEnd;
@end

@interface XMLElementStream : NSObject 

+(void) registerElementFactory:(Class)factory;

-(instancetype) init;

-(instancetype) initWithListener: (id<XMLElementStreamListener>)listener;

-(void) pushData: (const char*)data ofSize:(NSUInteger)datasz;
-(void) pushData: (const char*)data;
-(void) reset;

+(XMLElement*) parseDataAtOnce: (const char*)buffer;

-(void) openElement: (const char*)name withAttributes:(const char**) atts;
-(void) closeElement: (const char*) name;
-(void) storeCData: (char*) cdata ofLength:(NSInteger) len;
-(void) enterNamespace: (const char*)prefix withURI:(const char*)uri;
-(void) exitNamespace: (const char*)prefix;

@property (readonly, copy) NSString *currentNamespaceURI;

@end



