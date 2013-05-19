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
@end

@implementation SearchTableViewController
@synthesize searchBar;
@synthesize searchItems = _searchItems, filteredSearchItems = _filteredSearchItems;
@synthesize multiSelectionEnabled = _multiSelectionEnabled;
@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _filteredSearchItems = [[NSMutableArray alloc] init];
        _selectedItems = [[NSMutableArray alloc] init];
        _createdItems = [[NSMutableArray alloc] init];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //add the save button if there's no back button
    if (!self.navigationItem.backBarButtonItem) {
        
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(saveButtonPressed:)];
        
        self.navigationItem.rightBarButtonItem = saveButton;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    SearchItem *thisItem = (tableView == self.searchDisplayController.searchResultsTableView) ? [_filteredSearchItems objectAtIndex:indexPath.row] : [_searchItems  objectAtIndex:indexPath.row];
    [cell.textLabel setText:thisItem.title];
    [cell.detailTextLabel setText:thisItem.subtitle];
    
    //if multi selection is enabled and this index is in the selected
    //items then add accessory
    //otherwise remove accesory
    if (_multiSelectionEnabled) {
        
        if ([_selectedItems containsObject:thisItem]) {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }
        else {
            [cell setAccessoryType:nil];
        }
            
        
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
        [_searchItems addObject:newItem];
        
        //add the new item to the selected items
        [_selectedItems addObject:newItem];
        
        //remove search results
        [self.searchBar setText:@""];
        [self.searchBar resignFirstResponder];
        [self.searchDisplayController setActive:NO animated:YES];
        [self.tableView reloadData];
        
        return;
    }
    
    if (_multiSelectionEnabled) {
        
        if ([_selectedItems containsObject:thisItem])
            [_selectedItems removeObject:thisItem];
        else
            [_selectedItems addObject:thisItem];
        
        [tableView reloadData];
        
    }
    

    
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
    if (_filteredSearchItems.count == 0) {
        
        SearchItem *addItem = [SearchItem searchItemWithTitle:[NSString stringWithFormat:@"Create \"%@\"", searchText, nil] subtitle:@"Add a new category"];
        [_filteredSearchItems addObject:addItem];
        
    }
}
@end
