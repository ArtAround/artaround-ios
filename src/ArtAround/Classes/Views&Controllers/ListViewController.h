//
//  ListViewController.h
//  ArtAround
//
//  Created by Brian Singer on 3/5/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArtListViewCell.h"
#import <CoreLocation/CoreLocation.h>

@protocol ListViewControllerDelegate;

@interface ListViewController : UITableViewController {
    NSMutableArray *_items;
    
    int _itemsShowing;
    
    id <ListViewControllerDelegate> delegate;
}

@property (nonatomic, strong) UIButton *addArtButton, *filterButton;
@property (nonatomic, strong) ArtListViewCell *customCell;
@property (nonatomic, strong) id <ListViewControllerDelegate> delegate;

- (id) initWithStyle:(UITableViewStyle)style items:(NSMutableArray*)items;
- (void) setItems:(NSMutableArray*)items;

@end


@protocol ListViewControllerDelegate
- (void) selectedArtAtIndex:(int)index;
- (void) selectedArt:(Art*)art;
- (NSDictionary*) currentLocation;
- (void)listViewFilterButtonPressed;
- (void)listViewAddArtButtonPressed;
@end