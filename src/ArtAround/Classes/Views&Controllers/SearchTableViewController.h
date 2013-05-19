//
//  SearchTableViewController.h
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTableViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>

{
    BOOL _isFiltered;
    NSMutableArray *_selectedItems, *_createdItems;
}

@property (retain, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) NSMutableArray *filteredSearchItems, *searchItems;
@property BOOL multiSelectionEnabled;


@end
