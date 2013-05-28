//
//  SearchTableViewController.h
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchTableViewDelegate;

@interface SearchTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

{
    BOOL _isFiltered;
    NSMutableArray *_createdItems;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *filteredSearchItems, *searchItems, *selectedItems;
@property BOOL multiSelectionEnabled;
@property (nonatomic, assign) id <SearchTableViewDelegate> delegate;

@end


@protocol SearchTableViewDelegate

- (void) searchTableViewController:(SearchTableViewController*)searchController didFinishWithSelectedItems:(NSArray*)items;

@end