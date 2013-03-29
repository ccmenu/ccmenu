//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1997-2000,2008 by Erik Doernenburg. All rights reserved.
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

#import "NSString+EDExtensions.h"


//=======================================================================================
    @implementation NSString(EDExtensions)
//=======================================================================================

static NSCharacterSet *iwsSet = nil;


//---------------------------------------------------------------------------------------
//	CONVENIENCE CONSTRUCTORS
//---------------------------------------------------------------------------------------

/*" Convenience factory method. "*/

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}


//---------------------------------------------------------------------------------------
//	VARIOUS EXTENSIONS
//---------------------------------------------------------------------------------------

/*" Returns a copy of the receiver with all whitespace left of the first non-whitespace character and right of the last whitespace character removed. "*/

- (NSString *)stringByRemovingSurroundingWhitespace
{
    NSRange		start, end, result;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        return @""; // string is empty or consists of whitespace only

    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if((start.location == 0) && (end.location == [self length] - 1))
        return self;

    result = NSMakeRange(start.location, end.location + end.length - start.location);

    return [self substringWithRange:result];	
}


/*" Returns YES if the receiver consists of whitespace only. "*/

- (BOOL)isWhitespace
{
    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    return ([self rangeOfCharacterFromSet:iwsSet].length == 0);

}


/*" Returns a copy of the receiver with all whitespace removed. "*/

- (NSString *)stringByRemovingWhitespace
{
    return [self stringByRemovingCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Returns a copy of the receiver with all characters from %set removed. "*/

- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set
{
    NSMutableString	*temp;

    if([self rangeOfCharacterFromSet:set options:NSLiteralSearch].length == 0)
        return self;
    temp = [[self mutableCopyWithZone:[self zone]] autorelease];
    [temp removeCharactersInSet:set];

    return temp;
}


/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forFont:(NSFont *)font
{
    return [self stringByAbbreviatingPathToWidth:maxWidth forAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}

/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forAttributes:(NSDictionary *)attributes
{
    NSString		*result;
    NSMutableArray	*components;
    int 			i;

    if([self sizeWithAttributes:attributes].width <= maxWidth)
        return self;

    result = [self stringByAbbreviatingWithTildeInPath];
    if([result sizeWithAttributes:attributes].width <= maxWidth)
        return result;

    components = [[[result pathComponents] mutableCopy] autorelease];
    if([[components objectAtIndex:0] isEqualToString:@"/"])
        [components removeObjectAtIndex:0];
    if([components count] < 2)
        return nil;
    [components replaceObjectAtIndex:0 withObject:@"..."];

    for(i = 1; i < [components count] - 1; i++)
        {
        [components removeObjectAtIndex:i];
        result = [NSString pathWithComponents:components];
        if([result sizeWithAttributes:attributes].width <= maxWidth)
            return result;
        }

    return nil;
}


/*" Returns YES if the receiver's prefix is equal to %string, comparing case insensitive. "*/

- (BOOL)hasPrefixCaseInsensitive:(NSString *)string
{
    return (([string length] <= [self length]) && ([self compare:string options:(NSCaseInsensitiveSearch|NSAnchoredSearch) range:NSMakeRange(0, [string length])] == NSOrderedSame));
}


/*" Returns YES if the receiver is equal to string "yes", comparing case insensitive. "*/

- (BOOL)boolValue
{
    if([self intValue] > 0)
        return YES;
    return [self caseInsensitiveCompare:@"yes"] == NSOrderedSame;
}


/*" Assumes the string contains an integer written in hexadecimal notation and returns its value. Uses #scanHexInt in #NSScanner. "*/

- (unsigned int)intValueForHex
{
    unsigned int	value;

    if([[NSScanner scannerWithString:self] scanHexInt:&value] == NO)
        return 0;
    return value;
}


/*" Returns yes if the string contains no text characters. Note that its length can still be non-zero. "*/

- (BOOL)isEmpty
{
  return [self isEqualToString:@""];
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableString(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSMutableString. "*/

/*" Removes all whitespace left of the first non-whitespace character and right of the last whitespace character. "*/

- (void)removeSurroundingWhitespace
{
    NSRange		start, end;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        {
        [self setString:@""];  // string is empty or consists of whitespace only
        return;
        }

    if(start.location > 0)
        [self deleteCharactersInRange:NSMakeRange(0, start.location)];
    
    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if(end.location < [self length] - 1)
        [self deleteCharactersInRange:NSMakeRange(NSMaxRange(end), [self length] - NSMaxRange(end))];
}


/*" Removes all whitespace from the string. "*/

- (void)removeWhitespace
{
    [self removeCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Removes all characters in %set from the string. "*/

- (void)removeCharactersInSet:(NSCharacterSet *)set
{
    NSRange         matchRange, searchRange, replaceRange;
    NSUInteger      length;

    length = [self length];
    matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:NSMakeRange(0, length)];
    while(matchRange.length > 0)
        {
        replaceRange = matchRange;
        searchRange.location = NSMaxRange(replaceRange);
        searchRange.length = length - searchRange.location;
        for(;;)
            {
            matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:searchRange];
            if((matchRange.length == 0) || (matchRange.location != searchRange.location))
                break;
            replaceRange.length += matchRange.length;
            searchRange.length -= matchRange.length;
            searchRange.location += matchRange.length;
            }
        [self deleteCharactersInRange:replaceRange];
        matchRange.location -= replaceRange.length;
        length -= replaceRange.length;
        }
}


//=======================================================================================
    @end
//=======================================================================================

