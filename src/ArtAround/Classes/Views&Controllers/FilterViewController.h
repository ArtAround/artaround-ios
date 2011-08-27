//
//  FilterViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/26/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utilities.h"

@interface FilterViewController : UITableViewController
{
	NSArray *_titles;
	NSMutableArray *_selectedTitles;
	BOOL _isTopLevel;
	FilterType _filterType;
}

- (id)init;
- (id)initWithFilterType:(FilterType)filterType;

@end
