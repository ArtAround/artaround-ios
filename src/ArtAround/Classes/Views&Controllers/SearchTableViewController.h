//
//  SearchTableViewController.h
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableViewDelegate;

@interface SearchTableViewController : UITableViewController

{
    BOOL _isFiltered;
    NSMutableArray *_createdItems;
}

@property (nonatomic, strong) NSMutableArray *filteredSearchItems, *searchItems, *selectedItems;
@property (nonatomic, strong) NSString *itemName;
@property BOOL multiSelectionEnabled, creationEnabled;
@property (nonatomic, weak) id <SearchTableViewDelegate> delegate;

@end


@protocol SearchTableViewDelegate

- (void) searchTableViewController:(SearchTableViewController*)searchController didFinishWithSelectedItems:(NSArray*)items;

@end
