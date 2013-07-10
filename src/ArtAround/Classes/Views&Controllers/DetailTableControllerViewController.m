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

static const float _kPhotoPadding = 3.0f;
static const float _kPhotoSpacing = 5.0f;
static const float _kPhotoInitialPaddingPortait = 3.0f;
static const float _kPhotoInitialPaddingForOneLandScape = 144.0f;
static const float _kPhotoInitialPaddingForTwoLandScape = 40.0f;
static const float _kPhotoInitialPaddingForThreeLandScape = 15.0f;
static const float _kPhotoWidth = 314.0f;
static const float _kPhotoHeight = 183.5f;
static const float _kMapHeight = 175.0f;
static const float _kMapPadding = 11.0f;
static const float _kPhotoScrollerHeight = 209.0f;

@interface DetailTableControllerViewController ()
- (void)setupImages;
- (CGFloat)heightForRow:(ArtDetailRow)detailRow;
- (UITableViewCell*)cellForRow:(ArtDetailRow)row;

- (void)editButtonPressed:(id)sender;
- (void)editSubmitButtonPressed:(id)sender;
- (void)editCancelButtonPressed:(id)sender;

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
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, _kMapPadding, self.tableView.frame.size.width - (_kMapPadding * 2), _kMapHeight)];
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
    
    //footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 45.0f)];
    [_footerView setBackgroundColor:[UIColor clearColor]];
    
    //footer buttons
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [_editButton setFrame:CGRectMake(0.0f, 0.0f, _footerView.frame.size.width, _footerView.frame.size.height)];
    [_editButton setBackgroundImage:[UIImage imageNamed:@"toolbarBackground.png"] forState:UIControlStateHighlighted];
    [_editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _cancelEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelEditButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_cancelEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelEditButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelEditButton setAlpha:0.0f];
    [_cancelEditButton setFrame:CGRectMake(0.0f, 0.0f, (_footerView.frame.size.width / 2.0f), _footerView.frame.size.height)];
    [_cancelEditButton addTarget:self action:@selector(editCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _submitEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitEditButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_submitEditButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_submitEditButton setTitle:@"Submit" forState:UIControlStateNormal];
    [_submitEditButton setAlpha:0.0f];
    [_submitEditButton setFrame:CGRectMake((_footerView.frame.size.width / 2.0f), 0.0f, (_footerView.frame.size.width / 2.0f), _footerView.frame.size.height)];
    [_submitEditButton addTarget:self action:@selector(editSubmitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:_editButton];
    [_footerView addSubview:_cancelEditButton];
    [_footerView addSubview:_submitEditButton];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Button Pressed
- (void)editButtonPressed:(id)sender
{
    _inEditMode = !_inEditMode;
    
    _editButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _cancelEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    _submitEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    
    [self.tableView reloadData];
}

- (void)editSubmitButtonPressed:(id)sender
{
    
}

- (void)editCancelButtonPressed:(id)sender
{
    _inEditMode = !_inEditMode;
    
    _editButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _cancelEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    _submitEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    
    [self.tableView reloadData];
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
    
    if (row == ArtDetailRowPhotos) {
        NSString *cellIdentifier = @"photosCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell addSubview:_photosScrollView];
    }
    else if (row == ArtDetailRowLocationMap) {
        NSString *cellIdentifier = @"mapCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        [cell addSubview:_mapView];
        return cell;
    }
    
    if (!_inEditMode) {
    
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
                cell.detailTextLabel.numberOfLines = 0;
                cell.textLabel.numberOfLines = 0;
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
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
            default:
                break;
        }
    }
    else {
        
        NSString *cellIdentifier = [NSString stringWithFormat:@"cellEdit%i", row];
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
                cell.detailTextLabel.numberOfLines = 1;
                cell.textLabel.numberOfLines = 0;
                
                switch (row) {
                    case ArtDetailRowTitle:
                    {
                        if (!_titleTextField) {
                            _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(107.0f, 0.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height)];
                            _titleTextField.placeholder = @"Title";
                            _titleTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _titleTextField.backgroundColor = [UIColor clearColor];
                            _titleTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                            _titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            _titleTextField.text = _art.title;
                            _titleTextField.tag = 5;
                        }
                        
                        [cell addSubview:_titleTextField];
                        break;
                    }
                    case ArtDetailRowCommissioned:
                    {
                        if (!_commissionedTextField) {
                            _commissionedTextField = [[UITextField alloc] initWithFrame:CGRectMake(107.0f, 0.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height)];
                            _commissionedTextField.placeholder = @"Commissioned By";
                            _commissionedTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _commissionedTextField.backgroundColor = [UIColor clearColor];
                            _commissionedTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                            _commissionedTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            if (_art.commissionedBy && _art.commissionedBy.length)
                                _commissionedTextField.text = _art.title;
                            _commissionedTextField.tag = 5;
                        }
                        
                        [cell addSubview:_commissionedTextField];
                        break;
                    }
                    case ArtDetailRowArtist:
                    {
                        if (!_artistTextField) {
                            _artistTextField = [[UITextField alloc] initWithFrame:CGRectMake(107.0f, 0.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height)];
                            _artistTextField.placeholder = @"Artist";
                            _artistTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _artistTextField.backgroundColor = [UIColor clearColor];
                            _artistTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                            _artistTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            if (_art.artist && _art.artist.length)
                                _artistTextField.text = _art.artist;
                            _artistTextField.tag = 5;
                        }
                        
                        [cell addSubview:_artistTextField];
                        break;
                    }
                    case ArtDetailRowYear:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                        break;
                    }
                    case ArtDetailRowLocationType:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                        break;
                    }
                    case ArtDetailRowLink:
                    {
                        if (!_urlTextField) {
                            _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(107.0f, 0.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height)];
                            _urlTextField.placeholder = @"Website";
                            _urlTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _urlTextField.backgroundColor = [UIColor clearColor];
                            _urlTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                            _urlTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//                            if (_art.artist && _art.artist.length)
//                                _urlTextField.text = _art.artist;
                            _urlTextField.tag = 5;
                        }
                        
                        [cell addSubview:_urlTextField];
                        break;
                    }
                    case ArtDetailRowCategory:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                        break;
                    }
                    default:
                        break;
                }
                
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
            default:
                break;
        }
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = (!_inEditMode) ? [NSString stringWithFormat:@"cell%i", indexPath.row] : [NSString stringWithFormat:@"cellEdit%i", indexPath.row];
    
    if (indexPath.row == ArtDetailRowPhotos) {
        cellIdentifier = @"photosCell";
    }
    else if (indexPath.row == ArtDetailRowLocationMap) {
        cellIdentifier = @"mapCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [self cellForRow:indexPath.row];
    }
    
    switch (indexPath.row) {
        case ArtDetailRowTitle:
        {
            cell.textLabel.text = @"title";
            cell.detailTextLabel.text = (_inEditMode) ? @"" : _art.title;
            break;
        }
        case ArtDetailRowCommissioned:
        {
            cell.textLabel.text = @"commissioned by";
            if (_art.commissionedBy && _art.commissionedBy.length)
                cell.detailTextLabel.text = (_inEditMode) ? @"" : _art.commissionedBy;
            break;
        }
        case ArtDetailRowArtist:
        {
            cell.textLabel.text = @"artist";
            if (_art.artist && _art.artist.length)
                cell.detailTextLabel.text = (_inEditMode) ? @"" : _art.artist;
            break;
        }
        case ArtDetailRowYear:
        {
            cell.textLabel.text = @"year";
            if (_art.year && _art.year != [NSNumber numberWithInt:0])
                cell.detailTextLabel.text = [_art.year stringValue];
            else {
                cell.detailTextLabel.text = @"Unkown";
            }
            break;
        }
        case ArtDetailRowLocationType:
        {
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = (_inEditMode) ? @"" : @"";
            
            if (_inEditMode)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            
            break;
        }
        case ArtDetailRowLink:
        {
            cell.textLabel.text = @"website";
            break;
        }
        case ArtDetailRowCategory:
        {
            cell.textLabel.text = @"categories";
            if (_art.categories && [_art.categories count] > 0)
                cell.detailTextLabel.text = [_art categoriesString];
            else
                cell.detailTextLabel.text = @"Categories";
            
            if (_inEditMode)
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            else
                cell.accessoryType = UITableViewCellAccessoryNone;
            
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

- (UIView*)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return _footerView;
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 40.0f;
    
    switch (indexPath.row) {
        case ArtDetailRowPhotos:
            height = _kPhotoScrollerHeight;
            break;
        
        case ArtDetailRowCategory:
            
            break;
            
        case ArtDetailRowDescription:
            
            break;
            
        case ArtDetailRowLocationDescription:
            
            break;
            
        case ArtDetailRowLocationMap:
            height = _kMapHeight + (_kMapPadding * 2.0f);
            break;
            
        default:
            break;
    }
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 45.0f;
}

#pragma mark - Image Scroll View
- (void)setupImages
{
	//loop through all the images and add an image view if it doesn't exist yet
	//update the url for each image view that doesn't have one yet
	//this method may be called multiple times as the flickr api returns info on each photo
    //insert the add button at the end of the scroll view
	EGOImageButton *prevView = nil;
	int totalPhotos = (_art && _art.photos != nil) ? [_art.photos count] + _userAddedImages.count : _userAddedImages.count;
	int photoCount = 0;
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES]];
	NSArray * sortedPhotos = [_art.photos sortedArrayUsingDescriptors:sortDescriptors];
    
    for (Photo *photo in sortedPhotos) {
		
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
		EGOImageButton *imageView = (EGOImageButton *)[_photosScrollView viewWithTag:(10 + [[_art.photos sortedArrayUsingDescriptors:sortDescriptors] indexOfObject:photo])];
		if (!imageView) {
			imageView = [[EGOImageButton alloc] initWithPlaceholderImage:nil];
			[imageView setTag:(10 + [[_art.photos sortedArrayUsingDescriptors:sortDescriptors] indexOfObject:photo])];
			[imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
			[imageView setClipsToBounds:YES];
			[imageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
			[imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
			[imageView.layer setBorderWidth:6.0f];
            [imageView addTarget:self action:@selector(artButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[_photosScrollView addSubview:imageView];
			[imageView release];
		}
		
		//set the image url
		if (imageView) {
			[imageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kArtAroundURL, photo.originalURL]]];
		}
		
		//adjust the imageView autoresizing masks when there are fewer than 3 images so that they stay centered
		if (imageView && totalPhotos < 3) {
			[imageView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
		}
		
		//store the previous view for reference
		//increment photo count
		prevView = imageView;
		photoCount++;
		
	}
    
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
		if (!imageView) {
			imageView = [[EGOImageButton alloc] initWithPlaceholderImage:nil];
			[imageView setTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
			[imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
			[imageView setClipsToBounds:YES];
			[imageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
			[imageView.layer setBorderColor:[UIColor whiteColor].CGColor];
			[imageView.layer setBorderWidth:6.0f];
            [imageView addTarget:self action:@selector(artButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[_photosScrollView addSubview:imageView];
			[imageView release];
            
		}
		
		//set the image url if it doesn't exist yet
		if (imageView && !imageView.imageURL) {
			[imageView setImage:thisUserImage forState:UIControlStateNormal];
		}
		
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
    UIButton *addImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addImgButton setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
    [addImgButton setImage:[UIImage imageNamed:@"uploadPhoto_noBg.png"] forState:UIControlStateNormal];
    [addImgButton.imageView setContentMode:UIViewContentModeCenter];
    [addImgButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [addImgButton.layer setBorderWidth:6.0f];
    [addImgButton setBackgroundColor:[UIColor lightGrayColor]];
    [addImgButton addTarget:self action:@selector(addImageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    //adjust the button's autoresizing mask when there are fewer than 3 images so that it stays centered
    if (totalPhotos < 3) {
        [addImgButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    }
    
    [_photosScrollView addSubview:addImgButton];
    
	//set the content size
	[_photosScrollView setContentSize:CGSizeMake(addImgButton.frame.origin.x + addImgButton.frame.size.width + _kPhotoSpacing, _photosScrollView.frame.size.height)];
	
	
}


@end
