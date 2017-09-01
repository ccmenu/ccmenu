
#import "CCMReorderableArrayController.h"
#import "CCMPreferencesController.h"
#import "CCMProjectDefaultValueTransformer.h"

/* Implementation based on mmalc's DNDArrayController, which was originally available at
   http://homepage.mac.com/mmalc/CocoaExamples/controllers.html
*/


NSString *CCMDraggedRowType = @"net.sourceforge.cruisecontrol.CCMenu.DraggedRowType";


@interface CCMTableCellView : NSTableCellView
@end

@implementation CCMTableCellView

- (void)drawRect:(NSRect)dirtyRect {
	BOOL isSelected = [(NSTableRowView *)[self superview] isSelected];

	CCMProjectDefaultValueTransformer *transformer = (CCMProjectDefaultValueTransformer *)[CCMProjectDefaultValueTransformer valueTransformerForName:CCMProjectDefaultValueTransformerName];
	NSAttributedString *s = [transformer transformedValue:self.objectValue isSelected:isSelected];
	[[self textField] setAttributedStringValue:s];

	[super drawRect:dirtyRect];
}

@end


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

- (BOOL)tableView:(NSTableView *)tv acceptDrop:(id <NSDraggingInfo>)info row:(NSInteger)rowArg dropOperation:(NSTableViewDropOperation)op
{
    NSUInteger row = (rowArg < 0) ? (NSUInteger)0 : rowArg;

    if([info draggingSource] != tableView)
        return NO;
    
    NSArray *rows = [[info draggingPasteboard] propertyListForType:CCMDraggedRowType];
    NSIndexSet *indexSet = [self indexSetFromRows:rows];
    
    [self moveObjectsInArrangedObjectsFromIndexes:indexSet toIndex:row];
    
    NSUInteger rowsAbove = [self rowsAboveRow:row inIndexSet:indexSet];
    NSRange range = NSMakeRange(row - rowsAbove, [indexSet count]);
    indexSet = [NSIndexSet indexSetWithIndexesInRange:range];
    [self setSelectionIndexes:indexSet];
    
    // This isn't ideal because it ties this otherwise abstract controller to preferences use
    [[NSNotificationCenter defaultCenter] postNotificationName:CCMPreferencesChangedNotification object:self];

    return YES;
}

- (void)moveObjectsInArrangedObjectsFromIndexes:(NSIndexSet *)indexSet toIndex:(NSUInteger)insertIndex
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
        [indexSet addIndex:[idx unsignedIntValue]];
    return indexSet;
}


- (NSUInteger)rowsAboveRow:(NSUInteger)row inIndexSet:(NSIndexSet *)indexSet
{
    NSUInteger currentIndex = [indexSet firstIndex];
    NSUInteger i = 0;
    while(currentIndex != NSNotFound) {
        if(currentIndex < row)
            i++;
        currentIndex = [indexSet indexGreaterThanIndex:currentIndex];
    }
    return i;
}


@end
