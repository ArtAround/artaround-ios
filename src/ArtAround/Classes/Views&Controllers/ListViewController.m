//
//  ListViewController.m
//  ArtAround
//
//  Created by Brian Singer on 3/5/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "ListViewController.h"
#import "Art.h"
#import "DetailViewController.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

@interface ListViewController ()

@end

@implementation ListViewController

@synthesize customCell = _customCell, favoriteButton = _favoriteButton;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithStyle:(UITableViewStyle)style items:(NSMutableArray*)items
{
    self = [self initWithStyle:style];
    if (self) {
        
        _items = [[NSMutableArray alloc] initWithArray:items];      
        _itemsShowing = 20;
    }
    return self;    
}

- (void) setItems:(NSMutableArray*)items 
{
    
    if (_items) {
        [_items release];
    }
    
    //set items
    _items = [[NSMutableArray alloc] initWithArray:items];
    
    NSDictionary *currentLocDict = [delegate currentLocation];
    CLLocation *currentLoc = [[CLLocation alloc] initWithLatitude:[[currentLocDict objectForKey:@"lat"] doubleValue] longitude:[[currentLocDict objectForKey:@"long"] doubleValue]];
    
    //sort items by distance
    for (Art *thisArt in _items) {
        CLLocation *thisLoc = [[CLLocation alloc] initWithLatitude:[thisArt.latitude doubleValue] longitude:[thisArt.longitude doubleValue]];
        NSNumber *thisDist = [NSNumber numberWithDouble:([thisLoc distanceFromLocation:currentLoc] / 1609.3)];
        [thisArt setDistance:[NSDecimalNumber decimalNumberWithDecimal:[thisDist decimalValue]]];
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [_items sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    
    [self.tableView reloadData];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = kBGlightBrown;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.tableView reloadData];
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return ([Utilities instance].selectedFilterType != FilterTypeNone) ? 30 : 0;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    //header view
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 30)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    [headerView setClipsToBounds:YES];
    
    //background image
    UIImageView *backgroundImage = [[UIImageView alloc] initWithFrame:CGRectInset(headerView.frame, -5, -10)];
    [backgroundImage setImage:[UIImage imageNamed:@"FilterBackground.png"]];
    [backgroundImage setBackgroundColor:[UIColor clearColor]];
    [backgroundImage setClipsToBounds:YES];
    [backgroundImage setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:backgroundImage];
    
    //filter label 
    UILabel *filterLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.frame, 0, 5)];
    [filterLabel setBackgroundColor:[UIColor clearColor]];
    [filterLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14]];
    [filterLabel setText:@"Filtered"];
    [filterLabel setTextAlignment:UITextAlignmentCenter];
    [filterLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [filterLabel setTextColor:[UIColor whiteColor]];
    
    
    [headerView addSubview:filterLabel];
    
    return headerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //determine height based on number of items and filter header
    float height;
    
    //if there are 5 or more items set at 35
    if (_items.count >= 5) {
        height = 35;
    }
    else if (_items.count > 0) {     //else account for number of items and header
        height = self.tableView.frame.size.height;
        
        //if we have a filtered header -30
        height -= ([Utilities instance].selectedFilterType == FilterTypeNone) ? 0 : 30;
        
        height -= (_items.count * 80);
    }
    else {
        height = self.tableView.frame.size.height;
        
        //if we have a filtered header -30
        height -= ([Utilities instance].selectedFilterType == FilterTypeNone) ? 0 : 30;
        
        height -= 80;
    }
    
    return height;
}

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    //determine height based on number of items and filter header
    float height;
    
    //if there are 5 or more items set at 35
    if (_items.count >= 5) {
        height = 35;
    }
    else if (_items.count > 0) {     //else account for number of items and header
        height = self.tableView.frame.size.height;
    
        //if we have a filtered header -30
        height -= ([Utilities instance].selectedFilterType == FilterTypeNone) ? 0 : 30;
        
        height -= (_items.count * 80);
    }
    else {
        height = self.tableView.frame.size.height;
        
        //if we have a filtered header -30
        height -= ([Utilities instance].selectedFilterType == FilterTypeNone) ? 0 : 30;
        
        height -= 80;
    }
    
    //header view
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height)];
    [footerView setClipsToBounds:YES];
    
    //initialize the share button
    _favoriteButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [_favoriteButton setImage:[UIImage imageNamed:@"Favorite.png"] forState:UIControlStateNormal];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavoritePressed.png"] forState:UIControlStateHighlighted];
    [_favoriteButton setImage:[UIImage imageNamed:@"FavoritePressed.png"] forState:UIControlStateSelected];    
    [_favoriteButton setFrame:CGRectMake(0.0f, footerView.frame.size.height - 35, _favoriteButton.imageView.image.size.width, _favoriteButton.imageView.image.size.height)];
    [_favoriteButton addTarget:delegate action:@selector(listViewFavoritesButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [_favoriteButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];
    [_favoriteButton setSelected:[delegate showFavorites]];
    [footerView addSubview:_favoriteButton];
    
    //initialize the filter button
    UIButton *aFilterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [aFilterButton setImage:[UIImage imageNamed:@"Filter.png"] forState:UIControlStateNormal];
    [aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackground.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateNormal];
    [aFilterButton setBackgroundImage:[[UIImage imageNamed:@"FilterBackgroundPressed.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:0] forState:UIControlStateHighlighted];
    [aFilterButton setFrame:CGRectMake(_favoriteButton.frame.size.width, footerView.frame.size.height - 35, footerView.frame.size.width - _favoriteButton.frame.size.width, aFilterButton.imageView.image.size.height)];
    [aFilterButton setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
    [aFilterButton setAdjustsImageWhenHighlighted:NO];
    [aFilterButton addTarget:delegate action:@selector(listViewFilterButtonPressed) forControlEvents:UIControlEventTouchUpInside];    
    [footerView addSubview:aFilterButton];
    
    return footerView;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 86;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return (_items.count == 0) ? 1 : (_items.count < _itemsShowing) ? _items.count : (_items.count == _itemsShowing) ? _itemsShowing : _itemsShowing + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if there are no items then show the no data cell
    if (_items.count == 0) {
        
        //get rid of the seperator
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.text = @"No Art Found";
        cell.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16];
        cell.textLabel.textColor = kBGdarkBrown;
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
 
        //reset the normal seperator style
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        tableView.separatorColor = [UIColor colorWithRed:(235.0f/255.0f) green:(235.0f/255.0f) blue:(235.0f/255.0f) alpha:0.7f];
        
        if (indexPath.row == _itemsShowing) {
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            cell.textLabel.text = @"Load More Art";
            cell.textLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:14];
            cell.textLabel.textColor = kBGdarkBrown;
            cell.textLabel.backgroundColor = [UIColor clearColor];
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            return cell;
        }
        else {
            static NSString *CellIdentifier = @"Cell";
            ArtListViewCell *cell = (ArtListViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                
                cell = [[ArtListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            //set bg color
            cell.contentView.backgroundColor = (indexPath.row % 2 == 0) ? [UIColor colorWithRed:(244.0f/255.0f) green:(244.0f/255.0f) blue:(244.0f/255.0f) alpha:1.0f] : [UIColor whiteColor];
            
            //set border color
            [cell.artImageView.layer setBorderColor:(indexPath.row % 2 == 0) ? [UIColor whiteColor].CGColor : [UIColor colorWithRed:(224.0f/255.0f) green:(224.0f/255.0f) blue:(224.0f/255.0f) alpha:1.0f].CGColor];
            [cell.artImageView.layer setBorderWidth:2.0f];
            
            //set art
            [cell setArt:[_items objectAtIndex:indexPath.row]];
            
            return cell;
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if there are no items return and do nothing
    if (_items.count == 0) 
        return;
    
    
    if (indexPath.row == _itemsShowing) {
        _itemsShowing += 20;
        [self.tableView reloadData];
    }
    else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [delegate selectedArtAtIndex:indexPath.row];
    }
}

@end
