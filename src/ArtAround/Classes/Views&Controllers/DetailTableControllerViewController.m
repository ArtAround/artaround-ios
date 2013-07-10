//
//  DetailTableControllerViewController.m
//  ArtAround
//
//  Created by Brian Singer on 7/9/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "DetailTableControllerViewController.h"
#import "ArtAroundAppDelegate.h"
#import "Art.h"
#import "Photo.h"
#import "EGOImageButton.h"
#import "PhotoImageView.h"
#import "AAAPIManager.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "Utilities.h"
#import "SearchItem.h"
#import "ArtParser.h"


@interface DetailTableControllerViewController ()
- (void)setupImages;
- (CGFloat)heightForRow:(ArtDetailRow)detailRow;
- (UITableViewCell*)cellForRow:(ArtDetailRow)row;
@end

@implementation DetailTableControllerViewController

- (id)initWithStyle:(UITableViewStyle)style art:(Art*)thisArt
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _art = thisArt;
        
        //initialize useraddedimages
        _userAddedImages = [[NSMutableArray alloc] init];
        
        //initialize edit mode
        _inEditMode = NO;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    //setup the map view
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, 0.0f, self.tableView.frame.size.width - (_kMapPadding * 2), _kMapHeight)];
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_mapView setShowsUserLocation:YES];
    
    
    //setup the images scroll view
    _photosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, _kPhotoScrollerHeight)];
    [_photosScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [_photosScrollView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
    [_photosScrollView setShowsVerticalScrollIndicator:NO];
    [_photosScrollView setShowsHorizontalScrollIndicator:NO];
    
    //year formatter
    _yearFormatter = [[NSDateFormatter alloc] init];
    [_yearFormatter setDateFormat:@"yyyy"];
    
    //setup images
    [self setupImages];

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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 11;
}

- (UITableViewCell*)cellForRow:(ArtDetailRow)row
{
    UITableViewCell *cell;
    NSString *cellIdentifier = [NSString stringWithFormat:@"cell%i", row];
    switch (row) {
        case ArtDetailRowTitle:
        case ArtDetailRowCommissioned:            
        case ArtDetailRowArtist:
        case ArtDetailRowYear:
        case ArtDetailRowLocationType:
        case ArtDetailRowLink:
        case ArtDetailRowCategory:            
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
            break;
        }
        case ArtDetailRowPhotos:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell addSubview:_photosScrollView];
            break;
        }
        case ArtDetailRowDescription:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            break;
        }
        case ArtDetailRowLocationDescription:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            break;
        }
        case ArtDetailRowLocationMap:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            [cell addSubview:_mapView];
            break;
        }
        default:
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [[NSString alloc] initWithFormat:@"cell%i", indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [self cellForRow:indexPath.row];
    }
    
    switch (indexPath.row) {
        case ArtDetailRowTitle:
        {
            cell.textLabel.text = @"title";
            cell.detailTextLabel.text = _art.title;
            break;
        }
        case ArtDetailRowCommissioned:
        {
            cell.textLabel.text = @"commissioned by";
            if (_art.commissionedBy && _art.commissionedBy.length)
                cell.detailTextLabel.text = _art.commissionedBy;
            break;
        }
        case ArtDetailRowArtist:
        {
            cell.textLabel.text = @"artist";
            if (_art.artist && _art.artist.length)
                cell.detailTextLabel.text = _art.artist;
            break;
        }
        case ArtDetailRowYear:
        {
            cell.textLabel.text = @"year";
            if (_art.year && _art.year != 0)
                cell.detailTextLabel.text = [_art.year stringValue];
            break;
        }
        case ArtDetailRowLocationType:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            break;
        }
        case ArtDetailRowLink:
        {
            cell.textLabel.text = @"website";
//            if (_art.year && _art.year != 0)
//                cell.detailTextLabel.text = [_art.year stringValue];
            break;
        }
        case ArtDetailRowCategory:
        {
            cell.textLabel.text = @"categories";
            if (_art.categories && [_art.categories count] > 0)
                cell.detailTextLabel.text = [_art categoriesString];
            break;
        }
        case ArtDetailRowDescription:
        {
            cell.textLabel.text = _art.description;
            break;
        }
        case ArtDetailRowLocationDescription:
        {
            cell.textLabel.text = _art.locationDescription;
            break;
        }
        default:
            break;
    }
    
    return cell;
}


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
- (CGFloat)heightForRow:(ArtDetailRow)detailRow
{
    CGFloat height = 40.0f;
    
    switch (detailRow) {
        case ArtDetailRowCategory:
        {
            break;
        }
            
        case ArtDetailRowDescription:
        {
            break;
        }
            
        case ArtDetailRowLocationDescription:
        {
            break;
        }
            
        case ArtDetailRowPhotos:
        {
            height = _kPhotoScrollerHeight;
            break;
        }
            
        case ArtDetailRowLocationMap:
        {
            height = _kMapHeight + (_kMapPadding * 2.0);
            break;
        }
            
        default:
            break;
    }
    
    return height;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 40.0f;
    
    switch (indexPath.row) {
        case ArtDetailRowCategory:
            
            break;
            
        case ArtDetailRowDescription:
            
            break;
            
        case ArtDetailRowLocationDescription:
            
            break;
            
        case ArtDetailRowLocationMap:
            height = 150.0f;
            break;
            
        default:
            break;
    }
    
    return height;
}

#pragma mark - Image Scroll View
- (void)setupImages
{
	//loop through all the images and add an image view if it doesn't exist yet
	//update the url for each image view that doesn't have one yet
	//this method may be called multiple times as the flickr api returns info on each photo
    //insert the add button at the end of the scroll view
	EGOImageButton *prevView = nil;
	int totalPhotos = _userAddedImages.count;
	int photoCount = 0;
    
    for (UIImage *thisUserImage in _userAddedImages) {
		
		//adjust the image view y offset
		float prevOffset = _kPhotoPadding;
		if (prevView) {
            
			//adjust offset based on the previous frame
			prevOffset = prevView.frame.origin.x + prevView.frame.size.width + _kPhotoSpacing;
			
		} else {
			
			//adjust the initial offset based on the total number of photos
			BOOL isPortrait = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
			if (isPortrait) {
				prevOffset = _kPhotoInitialPaddingPortait;
			} else {
				
				switch (totalPhotos) {
					case 1:
						prevOffset = _kPhotoInitialPaddingForOneLandScape;
						break;
						
					case 2:
						prevOffset = _kPhotoInitialPaddingForTwoLandScape;
						break;
						
					case 3:
					default:
						prevOffset = _kPhotoInitialPaddingForThreeLandScape;
						break;
				}
				
			}
            
		}
		
		//grab existing or create new image view
		EGOImageButton *imageView = (EGOImageButton *)[_photosScrollView viewWithTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
        UIButton *deleteButton = (UIButton*)[imageView viewWithTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
        
		if (!imageView) {
			imageView = [[EGOImageButton alloc] initWithPlaceholderImage:nil];
			[imageView setClipsToBounds:YES];
			[imageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setImage:thisUserImage forState:UIControlStateNormal];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
            [imageView addTarget:self action:@selector(artButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setFrame:CGRectMake(2.0f, 2.0f, 20.0f, 20.0f)];
            [deleteButton setBackgroundColor:[UIColor clearColor]];
            [deleteButton.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [deleteButton setBackgroundImage:[UIImage imageNamed:@"closeIcon.png"] forState:UIControlStateNormal];
            [deleteButton setAdjustsImageWhenHighlighted:YES];
            [deleteButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            [deleteButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
            [deleteButton addTarget:self action:@selector(photoDeleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [deleteButton setTag:imageView.tag];
            [imageView addSubview:deleteButton];
            
            
			[_photosScrollView addSubview:imageView];
            [_imageButtons addObject:imageView];
            
            
		}
        
        [imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
        [imageView setTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
        [deleteButton setTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
		
		
		//adjust the imageView autoresizing masks when there are fewer than 3 images so that they stay centered
		if (imageView && totalPhotos < 3) {
			[imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		}
		
		//store the previous view for reference
		//increment photo count
		prevView = imageView;
		photoCount++;
		
	}
	
    
    
    //get the add button's offset
    float prevOffset = _kPhotoPadding;
    if (prevView) {
        //adjust offset based on the previous frame
        prevOffset = prevView.frame.origin.x + prevView.frame.size.width + _kPhotoSpacing;
        
    } else {
        
        //adjust the initial offset based on the total number of photos
        BOOL isPortrait = (UIInterfaceOrientationIsPortrait(self.interfaceOrientation));
        if (isPortrait) {
            prevOffset = _kPhotoInitialPaddingPortait;
        } else {
            prevOffset = _kPhotoInitialPaddingForOneLandScape;
        }
    }
    
    //setup the add image button
    UIButton *addImgButton = (UIButton*)[_photosScrollView viewWithTag:_kAddImageTagBase];
    
    if (!addImgButton) {
        addImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [addImgButton setImage:[UIImage imageNamed:@"uploadPhoto_noBg.png"] forState:UIControlStateNormal];
        [addImgButton setTag:_kAddImageTagBase];
        [addImgButton.imageView setContentMode:UIViewContentModeCenter];
        [addImgButton setBackgroundColor:[UIColor colorWithRed:(170.0f/255.0f) green:(170.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0f]];
        [addImgButton addTarget:self action:@selector(addImageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [_photosScrollView addSubview:addImgButton];
    }
    
    if (_userAddedImages.count == 0) {
        
        [addImgButton setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
        
        //adjust the button's autoresizing mask when there are fewer than 3 images so that it stays centered
        if (totalPhotos < 3) {
            [addImgButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        }
        
    }
    
    
	//set the content size
	[_photosScrollView setContentSize:CGSizeMake(addImgButton.frame.origin.x + addImgButton.frame.size.width + _kPhotoSpacing, _photosScrollView.frame.size.height)];
	
	
}


@end
