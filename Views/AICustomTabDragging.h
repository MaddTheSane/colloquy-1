//
//  AICustomTabDragging.h
//  Adium
//
//  Created by Adam Iser on Sat Mar 06 2004.
//  Copyright (c) 2004 __MyCompanyName__. All rights reserved.
//

#define TAB_CELL_IDENTIFIER                     @"Tab Cell Identifier"

#define AICustomTabDragWillBegin	@"AICustomTabDragWillBegin"
#define AICustomTabDragDidComplete	@"AICustomTabDragDidComplete"

@class AICustomTabCell,AICustomTabDragWindow, AICustomTabsView;

@interface AICustomTabDragging : NSObject {
	AICustomTabCell         *dragTabCell;			//Custom tab cell being dragged
	NSSize                  dragOffset;				//Offset of cursor on dragged image
	BOOL					selectTabAfterDrag;		//Drag is occuring in the background, do not select after dropping
	AICustomTabsView        *sourceTabBar;			//source tabBar of the drag
	AICustomTabsView        *destTabBar;			//tabBar currently being hovered by the drag
	AICustomTabsView 		*_destinationOfLastDrag;//last tabbar to be dragged into (used to fix a cursor tracking issue)
	AICustomTabDragWindow	*tabDragWindow;			//drag window used for custom drag animations
}

+ (AICustomTabDragging *)sharedInstance;
- (void)dragTabCell:(AICustomTabCell *)inTabCell fromCustomTabsView:(AICustomTabsView *)sourceView withEvent:(NSEvent *)inEvent selectTab:(BOOL)shouldSelect;

@property (strong) AICustomTabsView *destinationTabView;
@property (readonly, strong) AICustomTabsView *sourceTabView;

- (void)setDestinationHoverPoint:(NSPoint)inPoint;
@property (readonly) NSSize sizeOfDraggedCell;
- (void)acceptDragIntoTabView:(AICustomTabsView *)destTabView atIndex:(NSInteger)destIndex;
@property (readonly, strong) NSTabViewItem *draggedTabViewItem;

@end
