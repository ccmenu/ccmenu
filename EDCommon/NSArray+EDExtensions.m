//---------------------------------------------------------------------------------------
//  NSArray+Extensions.m created by erik on Thu 28-Mar-1996
//  @(#)$Id: NSArray+Extensions.m,v 2.4 2008-04-21 05:54:19 znek Exp $
//
//  Copyright (c) 1996,1999,2008 by Erik Doernenburg. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "NSArray+EDExtensions.h"


static NSComparisonResult compareAttributes(id object1, id object2, void *context)
{
    // The cast of the first value to an NSString is merely to avoid a compiler warning that compare:
    // is declared in several classes. It does not limit the attribute values to strings.
    return [(NSString *)[object1 valueForKey:(id)context] compare:[object2 valueForKey:(id)context]];
}


//=======================================================================================
    @implementation NSArray(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSArray. "*/

//---------------------------------------------------------------------------------------

/*" If the array contains exactly one object this is returned. Otherwise an #NSInternalInconsistencyException is raised. "*/

- (id)singleObject
{
    if([self count] != 1)
        [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to retrieve single object from an array that contains %ld objects.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [self count]];
    return [self objectAtIndex:0];
}

//---------------------------------------------------------------------------------------

/*" Return the object at index 0 or !{nil} if the array is empty. "*/

- (id)firstObject
{
    if([self count] == 0)
        return nil;
    return [self objectAtIndex:0];
}

//---------------------------------------------------------------------------------------

/*" Returns a new array that is a copy of the receiver with the objects arranged in reverse. "*/

- (NSArray *)reversedArray
{
    return [[self reverseObjectEnumerator] allObjects];
}


/*" Returns a new array that is a copy of the receiver with the objects rearranged randomly. "*/

- (NSArray *)shuffledArray
{
    NSMutableArray *copy = [[self mutableCopyWithZone:[self zone]] autorelease];
    [copy shuffle];
    return copy;
}


/*" Returns a new array that is a copy of the receiver with the objects sorted objects according to their compare: method "*/

- (NSArray *)sortedArray
{
    return [self sortedArrayUsingSelector:@selector(compare:)];
}


/*" Returns a new array that is a copy of the receiver with the objects sorted according to the values of their attribute %{attributeName}. These are retrieved using key/value coding. "*/

- (NSArray *)sortedArrayByComparingAttribute:(NSString *)attributeName
{
    return [self sortedArrayUsingFunction:compareAttributes context:attributeName];
}


/*" If the receiver contains instances of #NSArray the objects from the embedded array are transferred to the receiver and the embedded array is deleted. This method works recursively which means that embedded arrays are also flattened before their contents are transferred. "*/

- (NSArray *)flattenedArray
{
    NSMutableArray	*flattenedArray;
    id				object;
    NSUInteger		i, n = [self count];

    flattenedArray = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];
    for(i = 0; i < n; i++)
        {
        object = [self objectAtIndex:i];
        if([object isKindOfClass:[NSArray class]])
            [flattenedArray addObjectsFromArray:[object flattenedArray]];
        else
            [flattenedArray addObject:object];
        }

    return flattenedArray;
}


//---------------------------------------------------------------------------------------

/*" Returns an array containing all objects from the receiver up to (not including) the object at %index. "*/

- (NSArray *)subarrayToIndex:(NSUInteger)index
{
    return [self subarrayWithRange:NSMakeRange(0, index)];
}


/*" Returns an array containing all objects from the receiver starting with the object at %index. "*/

- (NSArray *)subarrayFromIndex:(NSUInteger)index
{
    return [self subarrayWithRange:NSMakeRange(index, [self count] - index)];
}


//---------------------------------------------------------------------------------------

/*" Returns YES if the receiver is contained in %otherArray at %offset. "*/

- (BOOL)isSubarrayOfArray:(NSArray *)other atOffset:(NSUInteger)offset
{
    NSUInteger	i, n = [self count];

    if(n > offset + [other count])
        return NO;
    for(i = 0; i < n; i++)
        if([[self objectAtIndex:i] isEqual:[other objectAtIndex:offset + i]] == NO)
            return NO;
    return YES;
}

//---------------------------------------------------------------------------------------

/*" Returns the first index at which %otherArray is contained in the receiver; or !{NSNotFound} otherwise. "*/

- (NSUInteger)indexOfSubarray:(NSArray *)other
{
    NSUInteger	i, n = [self count], length, location = 0;

    do
        {
        if((length = n - location - [other count] + 1) <= 0)
            return NSNotFound;
        if((i = [self indexOfObject:[other objectAtIndex:0] inRange:NSMakeRange(location, length)]) == NSNotFound)
            return NSNotFound;
        location = i + 1;
        }
    while([other isSubarrayOfArray:self atOffset:i] == NO);

    return i;
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableArray(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSMutableArray. "*/


/*" Randomly changes the order of the objects in the receiving array. "*/

- (void)shuffle
{
    NSInteger i, j, n;
    id	d;

    n = [self count];
    for(i = n - 1; i >= 0; i--)
        {
        j = random() % n;
        if(j == i)
            continue;
        d = [[self objectAtIndex:i] retain];
        [self replaceObjectAtIndex:i withObject:[self objectAtIndex:j]];
        [self replaceObjectAtIndex:j withObject:d];
        [d release];
        }
}


/*" Sorts objects according to their compare: method "*/

- (void)sort
{
    [self sortUsingSelector:@selector(compare:)];
}


/*" Sorts objects according to the values of their %{attributeName}. These are retrieved using key/value coding. "*/

- (void)sortByComparingAttribute:(NSString *)attributeName
{
    [self sortUsingFunction:compareAttributes context:attributeName];
}


//=======================================================================================
   @end
//=======================================================================================



