//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.h,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1997-2000 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/NSString.h>

@class NSFileHandle, NSFont, EDObjectPair;

/*" Various common extensions to #NSString. "*/

@interface NSString(EDExtensions)

/*" Convenience factory methods "*/
+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

/*" Handling whitespace "*/
- (NSString *)stringByRemovingSurroundingWhitespace;
- (BOOL)isWhitespace;
- (NSString *)stringByRemovingWhitespace;
- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set;

/*" Comparisons "*/
- (BOOL)hasPrefixCaseInsensitive:(NSString *)string;
- (BOOL)isEmpty;

/*" Conversions "*/
- (BOOL)boolValue;
- (unsigned int)intValueForHex;

/*" Abbreviating paths "*/
- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forFont:(NSFont *)font;
- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forAttributes:(NSDictionary *)attributes;

@end

/*" Various common extensions to #NSMutableString. "*/

@interface NSMutableString(EDExtensions)

/*" Removing characters "*/
- (void)removeWhitespace;
- (void)removeCharactersInSet:(NSCharacterSet *)set;

@end
