//
//  SearchTableViewController.m
//  ArtAround
//
//  Created by Brian Singer on 5/19/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "SearchTableViewController.h"
#import "SearchItem.h"

@interface SearchTableViewController ()
-(void)filterContentForSearchText:(NSString*)searchText;
- (BOOL) items:(NSArray*)items containsItem:(NSObject*)item;
@end

@implementation SearchTableViewController
@synthesize searchBar;
@synthesize searchItems = _searchItems, filteredSearchItems = _filteredSearchItems, selectedItems = _selectedItems;
@synthesize multiSelectionEnabled = _multiSelectionEnabled, creationEnabled = _creationEnabled;
@synthesize delegate;
@synthesize itemName = _itemName;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _filteredSearchItems = [[NSMutableArray alloc] init];
        _selectedItems = [[NSMutableArray alloc] init];
        _createdItems = [[NSMutableArray alloc] init];
        _creationEnabled = YES;
        _itemName = @"category";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //add the save button if there's no back button
    if (!self.navigationItem.backBarButtonItem) {
        
        //setup back button
        UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
        [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:backButtonImage forState:UIControlStateNormal];
        [backButton setContentMode:UIViewContentModeCenter];
        UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        [self.navigationItem setLeftBarButtonItem:backButtonItem];
        
        //setup save button
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55.0f, 30.0f)];
        [saveButton addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [saveButton setBackgroundColor:[UIColor colorWithRed:(241.0f/255.0f) green:(164.0f/255.0f) blue:(162.0f/255.0f) alpha:1.0f]];
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]];
        UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
        [self.navigationItem setRightBarButtonItem:saveButtonItem];
        
//        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = saveButtonItem;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSelectedItems:(NSMutableArray *)newSelectedItems
{
    _selectedItems = [[NSMutableArray alloc] initWithArray:newSelectedItems];
    
    for (NSObject *thisItem in _selectedItems) {
        
        SearchItem *newItem = nil;
        
        //String
        if ([thisItem isKindOfClass:[NSString class]]) {
            
            newItem = [SearchItem searchItemWithTitle:(NSString*)thisItem subtitle:@""];
            
            
        }
        //Search Item
        else if ([thisItem isKindOfClass:[SearchItem class]]) {
            
            newItem = [SearchItem searchItemWithTitle:[(SearchItem*)thisItem title] subtitle:[(SearchItem*)thisItem subtitle]];
            
        }
        
        //check if the newItem is in the search items list and add if not
        if (newItem && ![self items:_searchItems containsItem:newItem]) {
            [_searchItems addObject:newItem];
        }
        
        
    }
    
    [self.tableView reloadData];
}

#pragma mark - Helpers
- (BOOL) items:(NSArray*)items containsItem:(NSObject*)item
{
    //grab the item title
    NSString *itemTitle = @"";
    if ([item isKindOfClass:[NSString class]]) {
        itemTitle = (NSString*)item;
    }
    //Search Item
    else if ([item isKindOfClass:[SearchItem class]]) {
        itemTitle = [(SearchItem*)item title];
    }
    
    for (NSObject *thisItem in items) {
        
        //String
        if ([thisItem isKindOfClass:[NSString class]]) {
            if ([itemTitle isEqualToString:(NSString*)thisItem])
                return YES;
        }
        //Search Item
        else if ([thisItem isKindOfClass:[SearchItem class]]) {
            if ([itemTitle isEqualToString:[(SearchItem*)thisItem title]])
                return YES;
        }
    }
    
    return NO;
}

- (BOOL) selectedItemsContainsItem:(NSObject*)item
{
        
    for (NSObject *thisItem in _selectedItems) {
        
        //String
        if ([thisItem isKindOfClass:[NSString class]]) {
            if ([[(SearchItem*)item title] isEqualToString:(NSString*)thisItem]) return YES;
        }
        //Search Item
        else if ([thisItem isKindOfClass:[SearchItem class]]) {
            return [self items:_selectedItems containsItem:item];
        }
    }
    
    return NO;
}

- (void) removeItemFromSelectedItems:(NSObject*)item
{
    NSString *itemTitle = @"";
    
    //String
    if ([item isKindOfClass:[NSString class]]) {
        itemTitle = (NSString*)item;
    }
    //Search Item
    else if ([item isKindOfClass:[SearchItem class]]) {
        itemTitle = [(SearchItem*)item title];
    }
    
    int index = -1;
    for (NSObject *thisItem in _selectedItems) {
        
        //String
        if ([thisItem isKindOfClass:[NSString class]]) {
            
            if ([(NSString*)thisItem isEqualToString:itemTitle]) {
                index = [_selectedItems indexOfObject:thisItem];
                break;
            }
            
        }
        //Search Item
        else if ([thisItem isKindOfClass:[SearchItem class]]) {
            
            if ([[(SearchItem*)thisItem title] isEqualToString:itemTitle]) {
                index = [_selectedItems indexOfObject:thisItem];
                break;
            }
        }
        
    }
    
    if (index != -1)
        [_selectedItems removeObjectAtIndex:index];
    
}

#pragma mark - Svae Button
- (void) saveButtonPressed:(id)sender
{
    
    if (self.delegate && [(id)self.delegate canPerformAction:@selector(searchTableViewController:didFinishWithSelectedItems:) withSender:self]) {
        
        [self.delegate searchTableViewController:self didFinishWithSelectedItems:_selectedItems];
        
    }
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return (tableView == self.searchDisplayController.searchResultsTableView) ? _filteredSearchItems.count : _searchItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    NSObject *thisItem = (tableView == self.searchDisplayController.searchResultsTableView) ? [_filteredSearchItems objectAtIndex:indexPath.row] : [_searchItems  objectAtIndex:indexPath.row];
    
    if ([thisItem isKindOfClass:[SearchItem class]]) {
        [cell.textLabel setText:[(SearchItem*)thisItem title]];
        [cell.detailTextLabel setText:[(SearchItem*)thisItem subtitle]];
    }
    else if ([thisItem isKindOfClass:[NSString class]]) {
        [cell.textLabel setText:(NSString*)thisItem];
        [cell.detailTextLabel setText:@""];
    }
    
    
    if ([self selectedItemsContainsItem:thisItem]) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else if (_selectedItems.count == 0 && (([thisItem isKindOfClass:[SearchItem class]] && [[(SearchItem*)thisItem title] isEqualToString:@"None"]) || ([thisItem isKindOfClass:[NSString class]] && [(NSString*)thisItem isEqualToString:@"None"]))) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
        
    
    
    return cell;
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    SearchItem *thisItem = (tableView == self.searchDisplayController.searchResultsTableView) ? [_filteredSearchItems objectAtIndex:indexPath.row] : [_searchItems  objectAtIndex:indexPath.row];
    
    //is the selected row an "add" row?
    NSRange createRange = [thisItem.title rangeOfString:@"Create \""];
    if (createRange.location != NSNotFound) {
        
        NSString *itemTitle = thisItem.title;
        NSRange categoryNameRange = NSMakeRange(createRange.length, itemTitle.length - createRange.length - 1); // - 1 because of the ending ni"
        NSString *categoryName = [itemTitle substringWithRange:categoryNameRange];
        SearchItem *newItem = [SearchItem searchItemWithTitle:categoryName subtitle:nil];
        
        //add the new item to search items
        if (![self items:_searchItems containsItem:newItem])
            [_searchItems addObject:newItem];
        
        //add the new item to the selected items
        if (![self items:_selectedItems containsItem:newItem]) {
            if (!_multiSelectionEnabled)
                [_selectedItems removeAllObjects];
            
            [_selectedItems addObject:newItem];
        }
        
        //remove search results
        [self.searchBar setText:@""];
        [self.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        [self.tableView reloadData];
        
        return;
    }
    
    if (_multiSelectionEnabled) {
        if ([self selectedItemsContainsItem:thisItem])
            [self removeItemFromSelectedItems:thisItem];
        else
            [_selectedItems addObject:thisItem];
    }
    else {
        
        if ([self selectedItemsContainsItem:thisItem])
            [_selectedItems removeAllObjects];
        else {
            [_selectedItems removeAllObjects];
            [_selectedItems addObject:thisItem];
        }
    }
    
    [tableView reloadData];
    


    
}

- (void)dealloc {
    [searchBar release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setSearchBar:nil];
    [super viewDidUnload];
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.tableView reloadData];
}

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredSearchItems removeAllObjects];
    // Filter the array using NSPredicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title contains[c] %@",searchText];
    _filteredSearchItems = [[NSMutableArray alloc] initWithArray:[_searchItems filteredArrayUsingPredicate:predicate]];
    
    //create the "add" row if there are not items
    if (_filteredSearchItems.count == 0 && _creationEnabled) {
        
        SearchItem *addItem = [SearchItem searchItemWithTitle:[NSString stringWithFormat:@"Create \"%@\"", searchText, nil] subtitle:[NSString stringWithFormat:@"Add a new %@", _itemName]];
        [_filteredSearchItems addObject:addItem];
        
    }
}
@end
