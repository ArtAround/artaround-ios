//
//  FilterViewController.m
//  ArtAround
//
//  Created by Brandon Jones on 8/26/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "FilterViewController.h"
#import "AAAPIManager.h"
#import "Utilities.h"
#import "MapViewController.h"

static NSArray *_kFilterTypes = nil;

@implementation FilterViewController

#pragma mark - Class Methods

+ (NSArray *)filterTypeTitles
{
	if (!_kFilterTypes) {
		_kFilterTypes = [[NSArray alloc] initWithObjects:@"Don't Filter", @"Category", @"Neighborhood", @"Title", @"Artist", nil];
	}
	return _kFilterTypes;
}

#pragma mark - View Lifecycle

- (id)init
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		
		//set the title
		[self setTitle:@"Filters"];
		
		//initialize array
		_selectedTitles = [[NSMutableArray alloc] init];
		
		//top level titles
		_titles = [[FilterViewController filterTypeTitles] retain];
		_isTopLevel = YES;
		_filterType = FilterTypeNone;
		
    }
    return self;
}

- (id)initWithFilterType:(FilterType)filterType
{
	self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
		
		//set the title based on the filter type
		[self setTitle:[[FilterViewController filterTypeTitles] objectAtIndex:filterType]];
		
		//set the proper filter type
		_filterType = filterType;
		
		//initialize array
		_selectedTitles = [[NSMutableArray alloc] initWithArray:[[Utilities instance] getFiltersForFilterType:_filterType]];
		
		switch (filterType) {
				
			case FilterTypeCategory:
				_titles = [[[AAAPIManager instance] categories] copy];
				break;
				
			case FilterTypeNeighborhood:
				_titles = [[[AAAPIManager instance] neighborhoods] copy];
				break;
				
			case FilterTypeTitle:
				_titles = [[[AAAPIManager instance] titles] copy];
				break;
				
			case FilterTypeArtist:
				_titles = [[[AAAPIManager instance] artists] copy];
				break;
				
			default:
				break;
		}
		
    }
    return self;
}

- (void)dealloc
{
	[_titles release];
	[_selectedTitles release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
	//set the UINavigationControllerDelegate delegate
	self.navigationController.delegate = self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//add a done button
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [_titles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FilterCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
	
	//set the cell title
	NSString *title = [_titles objectAtIndex:indexPath.row];
	cell.textLabel.text = title;
	
	//update the cell accessory depending on the selected filters and filter types
	if (_isTopLevel) {
		
		//top level
		if (indexPath.row == [[Utilities instance] selectedFilterType]) {
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		} else {
			if (indexPath.row == 0) {
				cell.accessoryType = UITableViewCellAccessoryNone;
			} else {
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
		}
		
	} else {
		
		//not top level
		if ([_selectedTitles count] == 0 && indexPath.row == 0) {
			
			//nothing is selected, default to selecting the first row
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			
		} else if ([_selectedTitles containsObject:title]) {
			
			//the item is selected, show a checkmark
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
			
		} else {
			
			//not selected
			cell.accessoryType = UITableViewCellAccessoryNone;
			
		}
		
	}

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	//deselect the row
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	//top level only one item can be selected
	//deeper levels are multi-select
	NSString *selectedTitle = [_titles objectAtIndex:indexPath.row];
	if (_isTopLevel) {
		
		//set the selected filter type
		[[Utilities instance] setSelectedFilterType:indexPath.row];
		
		//reload all visible cells
		[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
		
	} else if (indexPath.row == 0) {
		
		//"all" or "none" selected, remove all others
		[_selectedTitles removeAllObjects];
		
		//update the filter
		[[Utilities instance] setFilters:nil forFilterType:_filterType];
		
		//reload all visible cells
		[tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
		
	} else {
			
		//add or remove the title from the selection array
		if ([_selectedTitles containsObject:selectedTitle]) {
			[_selectedTitles removeObject:selectedTitle];
		} else {
			[_selectedTitles addObject:selectedTitle];
		}
		
		//update the filter
		[[Utilities instance] setFilters:_selectedTitles forFilterType:_filterType];
		
		//reload the cell
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:indexPath.section], indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
		
	}

	//if this is the top level?
	if (_isTopLevel && indexPath.row != 0) {
			
		//dig deeper based on the filter type selected
		FilterViewController *filterController = [[FilterViewController alloc] initWithFilterType:indexPath.row];
		[self.navigationController pushViewController:filterController animated:YES];
		[filterController release];			
	}
	
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
	//if the filters were updated, update the map
	if ([viewController isKindOfClass:[MapViewController class]]) {
		[(MapViewController *)viewController updateArt];
	}
}

#pragma mark - Interface Actions

- (void)doneButtonTapped
{
	[self.navigationController popToRootViewControllerAnimated:YES];
}

@end
