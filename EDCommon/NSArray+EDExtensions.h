//---------------------------------------------------------------------------------------
//  NSArray+Extensions.h created by erik on Thu 28-Mar-1996
//  @(#)$Id: NSArray+Extensions.h,v 2.2 2003-01-25 22:33:49 erik Exp $
//
//  Copyright (c) 1996, 1999, 2008 by Erik Doernenburg. All rights reserved.
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

#import <Foundation/NSArray.h>

/*" Various common extensions to #NSArray. "*/

@interface NSArray(EDExtensions)

/*" Retrieving individual objects "*/
- (id)singleObject;
- (id)firstObject;

/*" Handling subarrays "*/
- (NSArray *)subarrayToIndex:(NSUInteger)index;
- (NSArray *)subarrayFromIndex:(NSUInteger)index;

- (BOOL)isSubarrayOfArray:(NSArray *)other atOffset:(NSUInteger)offset;
- (NSUInteger)indexOfSubarray:(NSArray *)other;

/*" Rearranging the array "*/
- (NSArray *)reversedArray;
- (NSArray *)shuffledArray;
- (NSArray *)sortedArray;
- (NSArray *)sortedArrayByComparingAttribute:(NSString *)attributeName;
- (NSArray *)flattenedArray;

@end


/*" Various common extensions to #NSMutableArray. "*/

@interface NSMutableArray(EDExtensions)
/*" Rearranging the array "*/
- (void)shuffle;
- (void)sort;
- (void)sortByComparingAttribute:(NSString *)attributeName;
@end
