//
//  CommentsTableViewController.m
//  ArtAround
//
//  Created by Brian Singer on 7/16/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "CommentsTableViewController.h"
#import "Comment.h"

@interface CommentsTableViewController ()

@end

@implementation CommentsTableViewController

@synthesize comments = _comments;

- (id)initWithStyle:(UITableViewStyle)style comments:(NSArray*)theComments
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _comments = [[NSArray alloc] initWithArray:theComments];
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MMM d, yyyy"];
        
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //setup back button
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton setContentMode:UIViewContentModeCenter];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];

 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return _comments.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier = [NSString stringWithFormat:@"Cell%li", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell && indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        cell.textLabel.textColor = [UIColor colorWithWhite:0.1 alpha:1.0];
        cell.detailTextLabel.textColor = [UIColor grayColor];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13.0f];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:13.0f];
        
    }
    else if (!cell && indexPath.row == 1) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0.0f, cell.frame.size.height-1.0f, cell.frame.size.width, 1.0f)];
        [sep setBackgroundColor:[UIColor grayColor]];
        [sep setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [cell addSubview:sep];
        
        cell.textLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f];
        cell.textLabel.numberOfLines = 0;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = [(Comment*)[_comments objectAtIndex:indexPath.section] name];
        cell.detailTextLabel.text = [_dateFormatter stringFromDate:[(Comment*)[_comments objectAtIndex:indexPath.section] createdAt]];
    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = [(Comment*)[_comments objectAtIndex:indexPath.section] text];
    }
    
    //set bg color
    cell.contentView.backgroundColor = (indexPath.section % 2 == 0) ? [UIColor colorWithRed:(244.0f/255.0f) green:(244.0f/255.0f) blue:(244.0f/255.0f) alpha:1.0f] : [UIColor whiteColor];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        return 25.0f;
        
    }
    else {
        
        NSString *text = [(Comment*)[_comments objectAtIndex:indexPath.section] text];
        CGSize reqSize = [text sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f] constrainedToSize:CGSizeMake(300.0f, 1000.0f)];
        return reqSize.height + 10.0f;
        
    }
    
    return 0;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

@end
