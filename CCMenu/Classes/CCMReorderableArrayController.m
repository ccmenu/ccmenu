
#import "CCMReorderableArrayController.h"
#import "CCMPreferencesController.h"

/* Implementation based on mmalc's DNDArrayController, which was originally available at
   http://homepage.mac.com/mmalc/CocoaExamples/controllers.html
*/


NSString *CCMDraggedRowType = @"net.sourceforge.cruisecontrol.CCMenu.DraggedRowType";


@implementation CCMReorderableArrayController

- (void)awakeFromNib
{
    [tableView registerForDraggedTypes:@[CCMDraggedRowType]];
	[super awakeFromNib];
}

- (BOOL)tableView:(NSTableView *)tv writeRows:(NSArray*)rows toPasteboard:(NSPasteboard*)pboard
{
	[pboard declareTypes:@[CCMDraggedRowType] owner:self];
    [pboard setPropertyList:rows forType:CCMDraggedRowType];
    return YES;
}

- (NSDragOperation)tableView:(NSTableView *)tv validateDrop:(id <NSDraggingInfo>)info proposedRow:(int)row proposedDropOperation:(NSTableViewDropOperation)op
{
    if([info draggingSource] != tableView)
        return NSDragOperationNone;
    [tv setDropRow:row dropOperation:NSTableViewDropAbove];
    return NSDragOperationMove;
}

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(int)row dropOperation:(NSTableViewDropOperation)op
{
	if(row < 0)
        row = 0;
    
    if([info draggingSource] != tableView)
        return NO;
    
    NSArray *rows = [[info draggingPasteboard] propertyListForType:CCMDraggedRowType];
    NSIndexSet *indexSet = [self indexSetFromRows:rows];
    
    [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
    
    int rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
    NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
    indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self setSelectionIndexes:indexSet];
    
    // This isn't ideal because it ties this otherwise abstract controller to preferences use
    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:self];

    return YES;
}

- (void)moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet *)indexSet toIndex:(unsigned int)insertIndex
{
    NSArray *objects = [self arrangedObjects];
    NSUInteger index = [indexSet lastIndex];
    
    int aboveInsertIndexCount = 0;
    id object;
    NSUInteger removeIndex;
    
    while(index != NSNotFound)
    {
        if(index >= insertIndex)
        {
            removeIndex = index + aboveInsertIndexCount;
            aboveInsertIndexCount += 1;
        }
        else
        {
            removeIndex = index;
            insertIndex -= 1;
        }
        object = [objects objectAtIndex:removeIndex];
        [self removeObjectAtArrangedObjectIndex:removeIndex];
        [self insertObject:object atArrangedObjectIndex:insertIndex];
        
        index = [indexSet indexLessThanIndex:index];
    }
}

- (NSIndexSet *)indexSetFromRows:(NSArray *)rows
{
    NSMutableIndexSet *indexSet = [NSMutableIndexSet indexSet];
    NSEnumerator *rowEnumerator = [rows objectEnumerator];
    NSNumber *idx;
    while((idx = [rowEnumerator nextObject]))
        [indexSet addIndex:[idx intValue]];
    return indexSet;
}


- (int)rowsAboveRow:(int)row inIndexSet:(NSIndexSet *)indexSet
{
    NSUInteger currentIndex = [indexSet firstIndex];
    int i = 0;
    while(currentIndex != NSNotFound) {
        if(currentIndex < row)
            i++;
        currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}


@end
