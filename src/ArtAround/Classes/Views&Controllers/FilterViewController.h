//
//  FilterViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/26/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	FilterTypeNone = 0,
	FilterTypeCategory = 1,
	FilterTypeNeighborhood = 2,
	FilterTypeTitle = 3,
	FilterTypeArtist = 4,
} FilterType;

@interface FilterViewController : UITableViewController
{
	NSArray *_titles;
	NSMutableArray *_selectedTitles;
	BOOL _isTopLevel;
}

- (id)init;
- (id)initWithFilterType:(FilterType)filterType;

@end
