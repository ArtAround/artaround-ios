//
//  DetailTableControllerViewController.m
//  ArtAround
//
//  Created by Brian Singer on 7/9/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "DetailTableControllerViewController.h"
#import "Art.h"
#import "Photo.h"
#import "Comment.h"
#import "Category.h"
#import "PhotoImageButton.h"
#import "PhotoImageView.h"
#import "AAAPIManager.h"
#import <QuartzCore/QuartzCore.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Social/Social.h>
#import "Utilities.h"
#import "SearchItem.h"
#import "ArtAnnotationView.h"
#import "ArtAroundAppDelegate.h"
#import "CommentsTableViewController.h"

static const float _kPhotoPadding = 5.0f;
static const float _kPhotoSpacing = 10.0f;
static const float _kPhotoInitialPaddingPortait = 5.0f;
static const float _kPhotoInitialPaddingForOneLandScape = 144.0f;
static const float _kPhotoInitialPaddingForTwoLandScape = 40.0f;
static const float _kPhotoInitialPaddingForThreeLandScape = 15.0f;
static const float _kPhotoWidth = 310.0f;
static const float _kPhotoHeight = 183.5f;
static const float _kMapHeight = 175.0f;
static const float _kMapPadding = 11.0f;
static const float _kPhotoScrollerHeight = 195.0f;
static const float _kRowBufffer = 20.0f;
static const float _kRowTextFieldWidth = 107.0f;


@interface DetailTableControllerViewController ()
- (void)setupImages;
- (UITableViewCell*)cellForRow:(ArtDetailRow)row;
- (void)editButtonPressed:(id)sender;
- (void)favoriteButtonPressed:(id)sender;
- (void)flagButtonPressed:(id)sender;
- (void)editSubmitButtonPressed:(id)sender;
- (void)editCancelButtonPressed:(id)sender;
- (void)doneButtonPressed:(id)sender;
- (void)dateDoneButtonPressed;
- (void)artButtonPressed:(id)sender;
- (void)addImageButtonTapped;
- (void)userAddedImage:(UIImage*)image withAttribution:(BOOL)withAtt;
- (BOOL)findAndResignFirstResponder;
- (void)textFieldChanged:(UITextField*)textField withText:(NSString*)text;
- (void)textFieldChanged:(id)textField;
- (void)artUploadFailed:(NSDictionary*)responseDict;
- (void)photoUploadCompleted:(NSDictionary*)responseDict;
- (void)photoUploadFailed:(NSDictionary*)responseDict;
- (void)setArt:(Art *)art forceDownload:(BOOL)force;
- (NSString *)shareURL;
- (NSString *)shareMessage;
- (void)shareButtonTapped;
@end

@implementation DetailTableControllerViewController

@synthesize currentLocation = _currentLocation;

- (id)initWithStyle:(UITableViewStyle)style art:(Art*)thisArt currentLocation:(CLLocation*)newLocation
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        _art = thisArt;
        
        //initialize useraddedimages
        _userAddedImages = [[NSMutableArray alloc] init];
        
        //initialize edit mode
        _inEditMode = NO;
        
        //initialize addedImageCount
        _addedImageCount = 0;
        
        //initialize artDict
        _newArtDictionary = [[NSMutableDictionary alloc] init];
        
        //bg color
        self.tableView.backgroundColor = [UIColor colorWithWhite:0.95f alpha:1.0f];
        
        //sep color
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        _currentLocation = newLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //track detail view
    [Utilities trackPageViewWithName:@"Detail"];
    
    //nav bar buttons
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
    [backButton addTarget:self.navigationController action:@selector(popToRootViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setContentMode:UIViewContentModeCenter];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    UIImage *shareButtonImage = [UIImage imageNamed:@"shareIcon.png"];
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, shareButtonImage.size.width + 10.0f, shareButtonImage.size.height)];
    [shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [shareButton setContentMode:UIViewContentModeCenter];
    [shareButton setImage:shareButtonImage forState:UIControlStateNormal];
    UIBarButtonItem *shareButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    [self.navigationItem setRightBarButtonItem:shareButtonItem];
    
    //setup the map view
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(_kMapPadding, _kMapPadding, self.tableView.frame.size.width - (_kMapPadding * 2), _kMapHeight)];
    [_mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [_mapView setShowsUserLocation:NO];
    [_mapView setDelegate:self];
    [_mapView.layer setBorderColor:[UIColor colorWithWhite:0.8 alpha:1.0f].CGColor];
    [_mapView.layer setBorderWidth:5.0f];
    
    //location
    _locationString = @"";
    _selectedLocation = [[CLLocation alloc] initWithLatitude:[_art.latitude floatValue] longitude:[_art.longitude floatValue]];
    
    //setup the images scroll view
    _photosScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, _kPhotoScrollerHeight)];
    [_photosScrollView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
    [_photosScrollView setBackgroundColor:[UIColor colorWithRed:111.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]];
    [_photosScrollView setShowsVerticalScrollIndicator:NO];
    [_photosScrollView setShowsHorizontalScrollIndicator:NO];
    [_photosScrollView setPagingEnabled:YES];
    
    
    //year formatter
    _yearFormatter = [[NSDateFormatter alloc] init];
    [_yearFormatter setDateFormat:@"yyyy"];

    //footer view
    _footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.tableView.frame.size.width, 35.0f)];
    [_footerView setBackgroundColor:[UIColor clearColor]];
    
    //footer buttons
    _favoriteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_favoriteButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_favoriteButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_favoriteButton setFrame:CGRectMake(0.0f, 0.0f, 50.0f, _footerView.frame.size.height)];
    [_favoriteButton setImage:[UIImage imageNamed:@"favoriteItIcon_plus.png"] forState:UIControlStateNormal];
    [_favoriteButton setImage:[UIImage imageNamed:@"favoriteItIcon_minus.png"] forState:UIControlStateSelected];
    [_flagButton setContentMode:UIViewContentModeCenter];
    [_favoriteButton setBackgroundImage:[UIImage imageNamed:@"toolbarBackground.png"] forState:UIControlStateHighlighted];
    [_favoriteButton addTarget:self action:@selector(favoriteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    if ([_art.favorite boolValue]) {
        [_favoriteButton setSelected:YES];
    }

    
    _flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_flagButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_flagButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_flagButton setFrame:CGRectMake(_footerView.frame.size.width - 50.0f, 0.0f, 50.0f, _footerView.frame.size.height)];
    [_flagButton setBackgroundImage:[UIImage imageNamed:@"toolbarBackground.png"] forState:UIControlStateHighlighted];
    [_flagButton setImage:[UIImage imageNamed:@"flagIcon.png"] forState:UIControlStateNormal];
    [_flagButton setContentMode:UIViewContentModeCenter];
    [_flagButton addTarget:self action:@selector(flagButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _editButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_editButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_editButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_editButton setTitle:@"Edit" forState:UIControlStateNormal];
    [_editButton setFrame:CGRectMake(50.0f, 0.0f, _footerView.frame.size.width-100.0f, _footerView.frame.size.height)];
    [_editButton setBackgroundImage:[UIImage imageNamed:@"toolbarBackground.png"] forState:UIControlStateHighlighted];
    [_editButton addTarget:self action:@selector(editButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _cancelEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancelEditButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_cancelEditButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_cancelEditButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [_cancelEditButton setAlpha:0.0f];
    [_cancelEditButton setFrame:CGRectMake(0.0f, 0.0f, (_footerView.frame.size.width / 2.0f), _footerView.frame.size.height)];
    [_cancelEditButton addTarget:self action:@selector(editCancelButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    _submitEditButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_submitEditButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_submitEditButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_submitEditButton setTitle:@"Submit" forState:UIControlStateNormal];
    [_submitEditButton setAlpha:0.0f];
    [_submitEditButton setFrame:CGRectMake((_footerView.frame.size.width / 2.0f), 0.0f, (_footerView.frame.size.width / 2.0f), _footerView.frame.size.height)];
    [_submitEditButton addTarget:self action:@selector(editSubmitButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImage *toolbarImage = [UIImage imageNamed:@"toolbarBackground.png"];
    _textDoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_textDoneButton setBackgroundImage:toolbarImage forState:UIControlStateNormal];
    [_textDoneButton setBackgroundColor:[UIColor colorWithWhite:0.4 alpha:0.9]];
    [_textDoneButton setTitleColor:[UIColor colorWithWhite:1.0f alpha:1.0f] forState:UIControlStateNormal];
    [_textDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [_textDoneButton setAlpha:0.0f];
    [_textDoneButton setFrame:CGRectMake(0.0f, 0.0f, _footerView.frame.size.width, _footerView.frame.size.height)];
    [_textDoneButton addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [_footerView addSubview:_editButton];
    [_footerView addSubview:_flagButton];
    [_footerView addSubview:_favoriteButton];
    [_footerView addSubview:_cancelEditButton];
    [_footerView addSubview:_submitEditButton];
    [_footerView addSubview:_textDoneButton];

    if (_art)
        [self setArt:_art forceDownload:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //location
    if (_locationString.length == 0) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:[_art.latitude floatValue] longitude:[_art.longitude floatValue]];
        [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error){
                DebugLog(@"Error durring reverse geocode");
            }
            
            if (placemarks.count > 0) {
                _locationString = [[NSString alloc] initWithString:[[placemarks objectAtIndex:0] name]];
                [self.tableView reloadData];
            }
            
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Helpers
- (void)setArt:(Art *)art forceDownload:(BOOL)force
{
	//download the full art object
    if (art && force) {
        //get the comments for this art
        [[AAAPIManager instance] downloadArtForSlug:art.slug target:self callback:@selector(artDownloadComplete) forceDownload:force];
    }
    //assign the art
    _art = art;
    
	if ([_art.photos allObjects] != nil && [[_art.photos allObjects] count] > 0) {
        //load images that we already have a source for
        [self setupImages];
    }
    
	//add the annotation for the art
	if ([_art.latitude doubleValue] && [_art.longitude doubleValue]) {
		
		//setup the coordinate
		CLLocationCoordinate2D artLocation;
		artLocation.latitude = [art.latitude doubleValue];
		artLocation.longitude = [art.longitude doubleValue];
		
		//create an annotation, add it to the map, and store it in the array
		ArtAnnotation *annotation = [[ArtAnnotation alloc] initWithCoordinate:artLocation title:art.title subtitle:art.artist];
		[_mapView addAnnotation:annotation];
        //set map region
        [Utilities zoomToFitMapAnnotations:_mapView];
	}
    
    //reload the table
    [self.tableView reloadData];
    
    //check the favorite
//    if (!_inEditMode)
//        [self.detailView.leftButton setSelected:[_art.favorite boolValue]];
    
}

//present the loading view
- (void)showLoadingView:(NSString*)msg
{
    //display loading alert view
    if (!_loadingAlertView) {
        _loadingAlertView = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.tag = 10;
        // Adjust the indicator so it is up a few pixels from the bottom of the alert
        indicator.center = CGPointMake(_loadingAlertView.bounds.size.width / 2, _loadingAlertView.bounds.size.height - 50);
        indicator.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [indicator startAnimating];
        [_loadingAlertView addSubview:indicator];
    }
    
    [_loadingAlertView setTitle:msg];
    [_loadingAlertView show];
    
    
    
    //display an activity indicator view in the center of alert
    UIActivityIndicatorView *activityView = (UIActivityIndicatorView*)[_loadingAlertView viewWithTag:10];
    [activityView setCenter:CGPointMake(_loadingAlertView.bounds.size.width / 2, _loadingAlertView.bounds.size.height - 44)];
    [activityView setFrame:CGRectMake(roundf(activityView.frame.origin.x), roundf(activityView.frame.origin.y), activityView.frame.size.width, activityView.frame.size.height)];
}

- (BOOL) findAndResignFirstResponder
{
    if (self.isFirstResponder) {
        [self resignFirstResponder];
        return YES;
    }
    
    if (_titleTextField.isFirstResponder) {
        [_titleTextField resignFirstResponder];
        return YES;
    }
    else if (_artistTextField.isFirstResponder) {
        [_artistTextField resignFirstResponder];
        return YES;
    }
    else if (_urlTextField.isFirstResponder) {
        [_urlTextField resignFirstResponder];
        return YES;
    }
    else if (_descriptionTextView.isFirstResponder) {
        [_descriptionTextView resignFirstResponder];
        return YES;
    }
    else if (_locationDescriptionTextView.isFirstResponder) {
        [_locationDescriptionTextView resignFirstResponder];
        return YES;
    }
    
    return NO;
}



#pragma mark - Button Pressed
- (void)favoriteButtonPressed:(id)sender
{
    
    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        Art *a = [_art MR_inContext:localContext];
        [a setFavorite:[NSNumber numberWithBool:!a.favorite.boolValue]];
    } completion:^(BOOL success, NSError *error) {
        
        _art = [Art MR_findFirstByAttribute:@"slug" withValue:_art.slug];
        
        //update the button
        [_favoriteButton setSelected:([_art.favorite boolValue])];
        
        //refresh the mapview so that the updated favorites are showing
        ArtAroundAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
        //    [appDelegate saveContext];
        [appDelegate.mapViewController updateArt];
        
        //track event
        [Utilities trackEvent:@"FavoriteButtonPressed" action:([_art.favorite boolValue]) ? @"favorited" : @"unfavorited" label:_art.title];
    }];
}

- (void)flagButtonPressed:(id)sender
{
    UIActionSheet *flagSheet = [[UIActionSheet alloc] initWithTitle:@"Flag Art" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Incorrect Info", @"Missing / Damaged", @"Duplicate", nil];
    [flagSheet setTag:_kFlagActionSheet];
    [flagSheet showInView:self.view];
}

- (void)editButtonPressed:(id)sender
{
    _inEditMode = !_inEditMode;
    
    //track map view
    [Utilities trackPageViewWithName:@"EditArtView"];
    
    _editButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _flagButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _favoriteButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _cancelEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    _submitEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    self.tableView.backgroundColor = (_inEditMode) ? kLightGray : [UIColor colorWithWhite:0.95f alpha:1.0f];
    
    [self.tableView reloadData];
    [self setupImages];
}

- (void)editSubmitButtonPressed:(id)sender
{
    //set slug
    [_newArtDictionary setObject:[Utilities urlEncode:_art.slug] forKey:@"slug"];
    
    //set the location
    //set the location
    if (_selectedLocation) {
        [_newArtDictionary setObject:[NSArray arrayWithObjects:[[NSNumber numberWithDouble:_selectedLocation.coordinate.latitude] stringValue], [[NSNumber numberWithDouble:_selectedLocation.coordinate.longitude] stringValue], nil] forKey:@"location"];
    } else {
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[_art.latitude floatValue] longitude:[_art.longitude floatValue]];
        [_newArtDictionary setObject:[NSArray arrayWithObjects:[[NSNumber numberWithDouble:loc.coordinate.latitude] stringValue], [[NSNumber numberWithDouble:loc.coordinate.longitude] stringValue], nil] forKey:@"location"];
    }
    
    //title
    if ([_newArtDictionary objectForKey:@"title"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"title"]] forKey:@"title"];
    else if (_art.title) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.title] forKey:@"title"];
        
    }
    
    //artist
    if ([_newArtDictionary objectForKey:@"artist"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"artist"]] forKey:@"artist"];
    else if (_art.artist) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.artist] forKey:@"artist"];
        
    }
    
    //commissionedBy
    if ([_newArtDictionary objectForKey:@"commissioned_by"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"commissioned_by"]] forKey:@"commissioned_by"];
    else if (_art.commissionedBy) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.commissionedBy] forKey:@"commissioned_by"];
        
    }
    
    //website
    if ([_newArtDictionary objectForKey:@"website"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"website"]] forKey:@"website"];
    else if (_art.website) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.website] forKey:@"website"];
        
    }
    
    //description
    if ([_newArtDictionary objectForKey:@"artDescription"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"artDescription"]] forKey:@"description"];
    else if (_art.artDescription) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.artDescription] forKey:@"description"];
        
    }
    
    //location_description
    if ([_newArtDictionary objectForKey:@"location_description"])
        [_newArtDictionary setObject:[Utilities urlEncode:[_newArtDictionary objectForKey:@"location_description"]] forKey:@"location_description"];
    else if (_art.locationDescription) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.locationDescription] forKey:@"location_description"];
        
    }
    
    //year  
    if (_yearString)
        [_newArtDictionary setObject:_yearString forKey:@"year"];
    else if (_art.year) {
        [_newArtDictionary setObject:[Utilities urlEncode:[_art.year stringValue]] forKey:@"year"];
    }
    
    //categories
    if ([_newArtDictionary objectForKey:@"categories"]) {
        [_newArtDictionary setObject:[Utilities urlEncode:[(NSArray*)[_newArtDictionary objectForKey:@"categories"] componentsJoinedByString:@","]] forKey:@"category"];
        [_newArtDictionary removeObjectForKey:@"categories"];
    }
    else if (_art.categories.count > 0) {
        [_newArtDictionary setObject:[Utilities urlEncode:_art.categoriesString] forKey:@"category"];
        
    }
    
    
    //call the submit request
    [[AAAPIManager instance] updateArt:_newArtDictionary withTarget:self callback:@selector(artUploadCompleted:) failCallback:@selector(artUploadFailed:)];
    
    [self showLoadingView:@"Uploading Art..."];
}

- (void)editCancelButtonPressed:(id)sender
{
    _inEditMode = !_inEditMode;
    
    _editButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _flagButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _favoriteButton.alpha = (_inEditMode) ? 0.0f : 1.0f;
    _cancelEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    _submitEditButton.alpha = (_inEditMode) ? 1.0f : 0.0f;
    self.tableView.backgroundColor = (_inEditMode) ? kLightGray : [UIColor colorWithWhite:0.95f alpha:1.0f];
    
    [_newArtDictionary removeAllObjects];
    
    [self.tableView reloadData];
    [self setupImages];
}

- (void)doneButtonPressed:(id)sender
{
    [self findAndResignFirstResponder];
}

- (void) dateDoneButtonPressed
{
    
    [UIView animateWithDuration:0.5f animations:^{
        
        [_datePicker setFrame:CGRectMake(0.0f, self.tableView.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height)];
        [_dateToolbar setFrame:CGRectMake(0.0f, self.tableView.frame.size.height, _dateToolbar.frame.size.width, _dateToolbar.frame.size.height)];
        
    } completion:^(BOOL finished) {
        [_datePicker removeFromSuperview];
        [_dateToolbar removeFromSuperview];
    }];
    
    [self.tableView reloadData];
}

- (void)artButtonPressed:(id)sender
{
    PhotoImageButton *button = (PhotoImageButton*)sender;
    NSInteger buttonTag = button.tag;
    
    //get this photo
    NSArray *sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"dateAdded" ascending:YES]];
	NSArray * sortedPhotos = [_art.photos sortedArrayUsingDescriptors:sortDescriptors];
    Photo *thisPhoto = [sortedPhotos objectAtIndex:buttonTag - 10];
    
    PhotoImageView *imgView = [[PhotoImageView alloc] initWithFrame:CGRectOffset(self.view.frame, 0, 0)];
    [imgView setPhotoImageViewDelegate:self];
    [imgView setContentMode:UIViewContentModeScaleAspectFit];
    [imgView setBackgroundColor:kFontColorDarkBrown];
    
    if (button.imageView.image)
        [imgView setImage:[UIImage imageWithCGImage:button.imageView.image.CGImage scale:1.0 orientation:UIImageOrientationUp]];
    else {
        if (thisPhoto.originalURL)
            [imgView setImageURL:button.imageURL];
    }
    
    //set the photo attribution if they exist
    if (thisPhoto.photoAttribution) {
        [(UILabel*)[imgView.photoAttributionButton viewWithTag:kAttributionButtonLabelTag] setText:[NSString stringWithFormat:@"Photo by %@", thisPhoto.photoAttribution]];
    }
    else {
        [(UILabel*)[imgView.photoAttributionButton viewWithTag:kAttributionButtonLabelTag] setText:@"Photo by anonymous user"];
    }
    
    if (thisPhoto.photoAttributionURL && [thisPhoto.photoAttributionURL isKindOfClass:[NSString class]] && thisPhoto.photoAttributionURL.length > 0) {
        [imgView setUrl:[NSURL URLWithString:thisPhoto.photoAttributionURL]];
    }
    
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view = imgView;
    
    [self.navigationController pushViewController:viewController animated:YES];
    DebugLog(@"Button Origin: %f", imgView.photoAttributionButton.frame.origin.y);
    
    [Utilities trackEvent:@"PhotoViewOpened" action:@"PhotoView" label:_art.title];
}

- (void)addImageButtonTapped
{
    
    UIActionSheet *imgSheet = [[UIActionSheet alloc] initWithTitle:@"Upload Photo" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take a Photo", @"Camera roll", nil];
    [imgSheet setTag:_kAddImageActionSheet];
    [imgSheet showInView:self.tableView];
    
}


#pragma mark - Art Upload Callback Methods

- (void)artUploadCompleted:(NSDictionary*)responseDict
{
    //flag to check if this was an edit or a new submission
    BOOL newArt = NO;
    
    
    if ([responseDict objectForKey:@"success"]) {
        
        //track event
        [Utilities trackEvent:@"ArtEdited" action:@"ArtEdit" label:_art.title];
        
        //parse new art and update this controller instance's art
        //grab the newly created slug if this is a creation
        if (!_art.slug) {
            [_newArtDictionary setObject:[responseDict objectForKey:@"success"] forKey:@"slug"];
            
            //it was new art
            newArt = YES;
        }
        
        //decode the objects
        for (NSString *thisKey in [_newArtDictionary allKeys]) {
            if ([[_newArtDictionary objectForKey:thisKey] isKindOfClass:[NSString class]])
                [_newArtDictionary setValue:[Utilities urlDecode:[_newArtDictionary objectForKey:thisKey]] forKey:thisKey];
        }
        if ([_newArtDictionary objectForKey:@"commissioned_by"] != nil) {
            [_newArtDictionary setObject:[_newArtDictionary objectForKey:@"commissioned_by"] forKey:@"commissionedBy"];
        }
        if ([_newArtDictionary objectForKey:@"description"] != nil) {
            [_newArtDictionary setObject:[_newArtDictionary objectForKey:@"description"] forKey:@"artDescription"];
        }
        [_newArtDictionary removeObjectForKey:@"description"];
        if ([_newArtDictionary objectForKey:@"location_description"] != nil) {
            [_newArtDictionary setObject:[_newArtDictionary objectForKey:@"location_description"] forKey:@"locationDescription"];
        }
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [Art MR_importFromObject:responseDict inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[responseDict objectForKey:@"slug"] inContext:localContext];
                
                //add categories
                if ([[responseDict objectForKey:@"category"] isKindOfClass:[NSArray class]]) {
                    
                    for (NSString *thisCatTitle in [responseDict objectForKey:@"category"]) {
                        
                        Category *catObject = [Category MR_findFirstByAttribute:@"categoryID" withValue:thisCatTitle];
                        if (catObject) {
                            [artRecord addCategoriesObject:catObject];
                        }
                        
                    }
                    
                }
                
                //add photos
                if ([[responseDict objectForKey:@"photos"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *photoObjects = [Photo MR_importFromArray:[responseDict objectForKey:@"photos"] inContext:localContext];
                    NSSet *photosSet = [[NSSet alloc] initWithArray:photoObjects];
                    [artRecord addPhotos:photosSet];
                    
                    
                }
                
                //add comments
                if ([[responseDict objectForKey:@"comments"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *commentObjects = [Comment MR_importFromArray:[responseDict objectForKey:@"comments"] inContext:localContext];
                    NSSet *commentSet = [[NSSet alloc] initWithArray:commentObjects];
                    [artRecord addComments:commentSet];
                    
                    
                }
                
            } completion:^(BOOL success, NSError *error) {
                _art = [Art MR_findFirstByAttribute:@"slug" withValue:[responseDict objectForKey:@"slug"]];
            }];
            
            
        }];
        
//        [[AAAPIManager managedObjectContext] lock];
//        _art = [ArtParser artForDict:_newArtDictionary inContext:[AAAPIManager managedObjectContext]];
//        [[AAAPIManager managedObjectContext] unlock];
        
        //merge context
//        [[AAAPIManager instance] performSelectorOnMainThread:@selector(mergeChanges:) withObject:[NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:[AAAPIManager managedObjectContext]] waitUntilDone:YES];
//        [(id)[[UIApplication sharedApplication] delegate] saveContext];
        
        [[(ArtAroundAppDelegate*)[[UIApplication sharedApplication] delegate] mapViewController] updateArt];
        
    }
    else {
        [self artUploadFailed:responseDict];
        return;
    }
    
    //take out of edit mode
    if (_inEditMode) {
        [self editButtonPressed:nil];
    }
    
    //dismiss loadign view
    [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    if (!newArt) {
        UIAlertView *moderationComment = [[UIAlertView alloc] initWithTitle:@"Thanks for your edit! Our moderators will approve it shortly" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [moderationComment show];
    }
    
    //reload the map view so the updated/new art is there
//    ArtAroundAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
//    [appDelegate saveContext];
    
    
}

- (void)artUploadFailed:(NSDictionary*)responseDict
{
    //dismiss loading view
    [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    //show fail alert
    UIAlertView *failedAlertView = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"The upload failed. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [failedAlertView show];
}

#pragma mark - Art Download Callback Methods
- (void)artDownloadComplete
{
//    //get art from core data
//	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Art" inManagedObjectContext:[AAAPIManager managedObjectContext]];
//	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//	[fetchRequest setEntity:entity];
//	[fetchRequest setFetchLimit:1];
//	[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"slug == %@", _art.slug]];
//
//    //fetch art
//	//execute fetch request
//	NSError *error = nil;
//	NSArray *queryItems = [[AAAPIManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    
    if (_art) {
        //reload the art
        [self setArt:_art forceDownload:NO];
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
    return 14;
}

- (UITableViewCell*)cellForRow:(ArtDetailRow)row
{
    UITableViewCell *cell = nil;
    
    if (row == ArtDetailRowPhotos) {
        NSString *cellIdentifier = @"photosCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, -400.0f, self.tableView.frame.size.width, 400 + _photosScrollView.frame.size.height)];
        [backView setBackgroundColor:kDarkGray];
        [cell addSubview:backView];
        [cell addSubview:_photosScrollView];
    }
    else if (row == ArtDetailRowBuffer) {
        NSString *cellIdentifier = @"bufferCell";
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if (!_inEditMode) {
    
        NSString *cellIdentifier = [NSString stringWithFormat:@"cell%i", row];
        switch (row) {
            case ArtDetailRowTitle:
            case ArtDetailRowCommissioned:            
            case ArtDetailRowArtist:
            case ArtDetailRowYear:
            case ArtDetailRowLocationType:
            case ArtDetailRowCategory:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
                cell.detailTextLabel.numberOfLines = 0;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0f];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                cell.detailTextLabel.contentMode = UIViewContentModeCenter;
                break;
            }
            case ArtDetailRowLink:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:cellIdentifier];
                cell.detailTextLabel.numberOfLines = 0;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0f];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                cell.detailTextLabel.contentMode = UIViewContentModeCenter;
                UIButton *link = [[UIButton alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width/2) - 47.0, 4.0, 32.0, 32.0)];
                [link setTag:998];
                [link setImage:[UIImage imageNamed:@"external_link"] forState:UIControlStateNormal];
                [link addTarget:self action:@selector(artLinkButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                [cell addSubview:link];
                break;
            }
            case ArtDetailRowDescription:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                cell.detailTextLabel.layer.backgroundColor = [UIColor whiteColor].CGColor;
                cell.detailTextLabel.numberOfLines = 0;
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                cell.detailTextLabel.textColor = [UIColor blackColor];
                
                break;
            }
            case ArtDetailRowLocationDescription:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                cell.detailTextLabel.numberOfLines = 0;
                cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                cell.detailTextLabel.textColor = [UIColor blackColor];
                break;
            }
            case ArtDetailRowComments:
            case ArtDetailRowAddComment:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
                cell.textLabel.numberOfLines = 1;
                cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
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
                cell.textLabel.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                cell.textLabel.backgroundColor = [UIColor clearColor];
                cell.detailTextLabel.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0f];
                
                
                UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(10.0f, 4.0f, 300.0f, cell.frame.size.height - 8.0f)];
                [backView setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
                [backView setBackgroundColor:[UIColor colorWithWhite:1.0f alpha:1.0f]];
                [cell addSubview:backView];
                [cell sendSubviewToBack:backView];
                
                switch (row) {
                    case ArtDetailRowTitle:
                    {
                        if (!_titleTextField) {
                            _titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(_kRowTextFieldWidth, 4.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height - 8.0f)];
                            _titleTextField.delegate = self;
                            _titleTextField.placeholder = @"Title";
                            _titleTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                            _titleTextField.returnKeyType = UIReturnKeyDone;
                            _titleTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _titleTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
                            _titleTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                            _titleTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            _titleTextField.text = _art.title;
                            _titleTextField.tag = 5;
                        }
                        
                        [cell addSubview:_titleTextField];
                        break;
                    }
                    case ArtDetailRowArtist:
                    {
                        if (!_artistTextField) {
                            _artistTextField = [[UITextField alloc] initWithFrame:CGRectMake(_kRowTextFieldWidth, 4.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height - 8.0f)];
                            _artistTextField.delegate = self;
                            _artistTextField.placeholder = @"Artist";
                            _artistTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
                            _artistTextField.returnKeyType = UIReturnKeyDone;
                            _artistTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _artistTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
                            _artistTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                            _artistTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            if (_art.artist && _art.artist.length)
                                _artistTextField.text = _art.artist;
                            _artistTextField.tag = 5;
                        }
                        
                        [cell addSubview:_artistTextField];
                        break;
                    }
                    case ArtDetailRowCommissioned:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                        break;
                    }
                    case ArtDetailRowYear:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                        break;
                    }
                    case ArtDetailRowLocationType:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
                        
                        
                        break;
                    }
                    case ArtDetailRowLink:
                    {
                        if (!_urlTextField) {
                            _urlTextField = [[UITextField alloc] initWithFrame:CGRectMake(_kRowTextFieldWidth, 4.0f, self.tableView.frame.size.width - 123.0f, cell.frame.size.height - 8.0f)];
                            _urlTextField.delegate = self;
                            _urlTextField.placeholder = @"Website";
                            _urlTextField.returnKeyType = UIReturnKeyDone;
                            _urlTextField.keyboardType = UIKeyboardTypeURL;
                            _urlTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                            _urlTextField.autoresizingMask = UIViewAutoresizingFlexibleHeight;
                            _urlTextField.backgroundColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
                            _urlTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
                            _urlTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
                            if (_art.website && _art.website.length)
                                _urlTextField.text = _art.website;
                            _urlTextField.tag = 5;
                        }
                        
                        [cell addSubview:_urlTextField];
                        break;
                    }
                    case ArtDetailRowCategory:
                    {
                        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f];
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
                
                if (!_descriptionTextView) {
                    _descriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 28.0f, 300.0f, 85.0f)];
                    _descriptionTextView.delegate = self;
                    _descriptionTextView.autoresizingMask = UIViewAutoresizingNone;
                    _descriptionTextView.backgroundColor = [UIColor whiteColor];
                    _descriptionTextView.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
                    _descriptionTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                    _descriptionTextView.text = _art.artDescription;
                }
                
                [cell addSubview:_descriptionTextView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 20.0f)];
                label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                label.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"About";
                [cell addSubview:label];
                
                break;
            }
            case ArtDetailRowLocationDescription:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                if (!_locationDescriptionTextView) {
                    _locationDescriptionTextView = [[UITextView alloc] initWithFrame:CGRectMake(10.0f, 28.0f, 300.0f, 85.0f)];
                    _locationDescriptionTextView.delegate = self;
                    _locationDescriptionTextView.autoresizingMask = UIViewAutoresizingNone;
                    _locationDescriptionTextView.backgroundColor = [UIColor whiteColor];
                    _locationDescriptionTextView.textColor = [UIColor colorWithWhite:0.0f alpha:1.0f];
                    _locationDescriptionTextView.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f];
                    _locationDescriptionTextView.text = _art.locationDescription;
                }
                
                [cell addSubview:_locationDescriptionTextView];
                
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 5.0f, 300.0f, 20.0f)];
                label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0f];
                label.textColor = [UIColor colorWithWhite:0.35 alpha:1.0f];
                label.backgroundColor = [UIColor clearColor];
                label.text = @"Where?";
                [cell addSubview:label];
                
                break;
            }
            case ArtDetailRowComments:
            case ArtDetailRowAddComment:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                break;
            }
            case ArtDetailRowLocationMap:
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
                
                break;
            }
            default:
                break;
        }
    }
    
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *cellIdentifier = (!_inEditMode) ? [NSString stringWithFormat:@"cell%li", indexPath.row] : [NSString stringWithFormat:@"cellEdit%li", indexPath.row];
    
    if (indexPath.row == ArtDetailRowPhotos) {
        cellIdentifier = @"photosCell";
    }
    else if (indexPath.row == ArtDetailRowLocationMap) {
        cellIdentifier = @"mapCell";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    // Configure the cell...
    if (cell == nil) {
        cell = [self cellForRow:(int)indexPath.row];
    }
    
    switch (indexPath.row) {
        case ArtDetailRowTitle:
        {
            cell.textLabel.text = @"title";
            cell.detailTextLabel.text = (_inEditMode) ? @"" : [Utilities urlDecode:_art.title];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            DebugLog(@"TITLE CELL WIDTH: %f", cell.detailTextLabel.frame.size.width);
            break;
        }
        case ArtDetailRowCommissioned:
        {
            cell.textLabel.text = @"commissioner";
            if (_art.commissionedBy && _art.commissionedBy.length > 0)
                cell.detailTextLabel.text = [Utilities urlDecode:_art.commissionedBy];
            else if ([_newArtDictionary objectForKey:@"commissioned_by"] && [[_newArtDictionary objectForKey:@"commissioned_by"] length] > 0)
                cell.detailTextLabel.text = [_newArtDictionary objectForKey:@"commissioned_by"];
            else {
                cell.detailTextLabel.text = @"";
                cell.textLabel.text = (_inEditMode) ? @"commissioner" : @"";
            }
            
            if (_inEditMode) {
                UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
                [arrow setFrame:CGRectMake(cell.frame.size.width - 60.0f, 0.0f, 30.0f, cell.frame.size.height)];
                [arrow setContentMode:UIViewContentModeLeft];
                [arrow setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
                cell.accessoryView = arrow;
                
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            break;
        }
        case ArtDetailRowArtist:
        {
            cell.textLabel.text = @"artist";
            
            if (_art.artist && _art.artist.length > 0) {
                cell.detailTextLabel.text = (_inEditMode) ? @"" : [Utilities urlDecode:_art.artist];
            } else {
                cell.textLabel.text = (_inEditMode) ? @"artist" : @"";
            }
            break;
        }
        case ArtDetailRowYear:
        {
            cell.textLabel.text = @"year";
            
            if (_yearString) {
                cell.detailTextLabel.text = _yearString;
            }
            else if (_art.year && _art.year != [NSNumber numberWithInt:0])
                cell.detailTextLabel.text = [_art.year stringValue];
            else {
                cell.detailTextLabel.text = (_inEditMode) ? @"Unkown" : @"";
                cell.textLabel.text = (_inEditMode) ? @"year" : @"";
            }
            
            if (_inEditMode) {
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            break;
        }
        case ArtDetailRowLocationType:
        {
            cell.textLabel.text = @"location";
            cell.detailTextLabel.text = [Utilities urlDecode:_locationString];
            
            if (_inEditMode) {
                UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
                [arrow setFrame:CGRectMake(cell.frame.size.width - 60.0f, 0.0f, 30.0f, cell.frame.size.height)];
                [arrow setContentMode:UIViewContentModeLeft];
                [arrow setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
                cell.accessoryView = arrow;
                
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            break;
        }
        case ArtDetailRowLink:
        {
            
            if (_art.website && _art.website.length > 0) {
                cell.detailTextLabel.text = (_inEditMode) ? @"" : [Utilities urlDecode:_art.website];
                if (!_inEditMode) {
                    cell.detailTextLabel.hidden = YES;
                } else {
                    cell.detailTextLabel.hidden = NO;
                }
                cell.textLabel.text = @"website";
            }
            else {
                cell.detailTextLabel.text = @"";
                cell.textLabel.text = (_inEditMode) ? @"website" : @"";
                UIView *link = [cell viewWithTag:998];
                if (link != nil) {
                    link.hidden = YES;
                }
            }
            
            break;
        }
        case ArtDetailRowCategory:
        {
            cell.textLabel.text = @"categories";
            
            if ([_newArtDictionary objectForKey:@"categories"] && [[_newArtDictionary objectForKey:@"categories"] count] > 0) {
                NSString *cats = [[_newArtDictionary objectForKey:@"categories"] componentsJoinedByString:@", "];
                cell.detailTextLabel.text = cats;
            }
            else if (_art.categories && [_art.categories count] > 0)
                cell.detailTextLabel.text = [_art categoriesString];
            else {
                cell.detailTextLabel.text = (_inEditMode) ? @"Categories" : @"";
                cell.textLabel.text = (_inEditMode) ? @"categories" : @"";
            }
            
            if (_inEditMode) {
                UIImageView *arrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow.png"]];
                [arrow setFrame:CGRectMake(cell.frame.size.width - 60.0f, 0.0f, 30.0f, cell.frame.size.height)];
                [arrow setContentMode:UIViewContentModeLeft];
                [arrow setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
                cell.accessoryView = arrow;
                
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            else {
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            
            break;
        }
        case ArtDetailRowDescription:
        {
            if (!_inEditMode) {
                if (_art.artDescription && _art.artDescription.length > 0) {
                    cell.textLabel.text = @"About";
                    cell.detailTextLabel.text = [Utilities urlDecode:_art.artDescription];
                }
                else {
                    cell.textLabel.text = @"";
                    cell.detailTextLabel.text = @"";
                }
            }
            break;
        }
        case ArtDetailRowLocationDescription:
        {
            if (!_inEditMode) {
                if (_art.locationDescription && _art.locationDescription.length > 0) {
                    cell.textLabel.text = @"Where?";
                    cell.detailTextLabel.text = [Utilities urlDecode:_art.locationDescription];
                }
                else {
                    cell.textLabel.text = @"";
                    cell.detailTextLabel.text = @"";
                }
            }
            break;
        }
        case ArtDetailRowComments:
        {
            if (_inEditMode) {
                cell.textLabel.text = @"";
            }
            else {
                cell.textLabel.text = [NSString stringWithFormat:@"Comments (%lu)", _art.comments.count];
                
                if (_art.comments.count > 0) {
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                
            }
            break;
        }
        case ArtDetailRowAddComment:
        {
            if (_inEditMode) {
                cell.textLabel.text = @"";
            }
            else {
                cell.textLabel.text = @"Add Comment";
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
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

- (void)artLinkButtonPressed:(UIButton*)sender
{
    UIView *superview = sender.superview;
    if (superview != nil) {
        while (![superview isKindOfClass:[UITableViewCell class]]) {
            superview = superview.superview;
        }
        UITableViewCell *cell = (UITableViewCell*)superview;
        NSString *url = cell.detailTextLabel.text;
        if( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (_inEditMode) {
        switch (indexPath.row) {
            case ArtDetailRowCommissioned:
            {
                SearchTableViewController *searchTableController = [[SearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
                NSMutableArray *searchItems = [[NSMutableArray alloc] initWithCapacity:[[[AAAPIManager instance] categories] count]];
                [searchItems addObject:[SearchItem searchItemWithTitle:@"None" subtitle:@""]];
                for (NSString * com in [[AAAPIManager instance] commissioners]) {
                    if (![com isEqualToString:@"All"])
                        [searchItems addObject:[SearchItem searchItemWithTitle:com subtitle:@""]];
                }
                
                [searchTableController setCreationEnabled:YES];
                [searchTableController setSearchItems:searchItems];
                [searchTableController setMultiSelectionEnabled:NO];
                [searchTableController setDelegate:self];
                [searchTableController setItemName:@"commissioner"];
                [searchTableController.tableView setTag:10];
                
                //add the categories if they exist
                if ([_newArtDictionary objectForKey:@"commissioned_by"]) {
                    SearchItem *item = [SearchItem searchItemWithTitle:[_newArtDictionary objectForKey:@"commissioned_by"] subtitle:@""];
                    NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithObjects:item, nil];
                    [searchTableController setSelectedItems:selectedItems];
                }
                else if (_art.commissionedBy) {
                    SearchItem *item = [SearchItem searchItemWithTitle:_art.commissionedBy subtitle:@""];
                    NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithObjects:item, nil];
                    [searchTableController setSelectedItems:selectedItems];
                }
                
                
                [self.navigationController pushViewController:searchTableController animated:YES];
                
                break;
            }
            case ArtDetailRowYear:
            {
                [self findAndResignFirstResponder];
                
                UIPickerView *datePicker = [[UIPickerView alloc] init];
                [datePicker setShowsSelectionIndicator:YES];
                [datePicker setDataSource:self];
                [datePicker setDelegate:self];
                [datePicker setBackgroundColor:[UIColor whiteColor]];
                
                UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(dateDoneButtonPressed)];
                [doneButton setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName,nil] forState:UIControlStateNormal];
                UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
                UIToolbar *dateToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.tableView.frame.size.height, self.tableView.frame.size.width, 44.0f)];
                [dateToolbar setBackgroundColor:[UIColor colorWithRed:67.0f/255.0f green:67.0f/255.0f blue:61.0f/255.0f alpha:1.0f]];
                [dateToolbar setBackgroundImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
                [dateToolbar setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIToolbarPositionAny];
                [dateToolbar setBarStyle:UIBarStyleBlack];
                [dateToolbar setTintColor:[UIColor clearColor]];
                
                
                [dateToolbar setItems:[NSArray arrayWithObjects:space, doneButton, nil]];
                
                _datePicker = datePicker;
                _doneButton = doneButton;
                _dateToolbar = dateToolbar;
                
                CGRect datePickerFrame = datePicker.frame;
                datePickerFrame.origin.y = self.view.frame.size.height + _dateToolbar.frame.size.height;
                [_datePicker setFrame:datePickerFrame];
                
                [[[[UIApplication sharedApplication] delegate] window] addSubview:dateToolbar];
                [[[[UIApplication sharedApplication] delegate] window] addSubview:datePicker];
                
                
                
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
                
                [UIView animateWithDuration:0.5f animations:^{
                    [_datePicker setFrame:CGRectMake(0.0f, [[[UIApplication sharedApplication] delegate] window].frame.size.height - _datePicker.frame.size.height, _datePicker.frame.size.width, _datePicker.frame.size.height)];
                    [_dateToolbar setFrame:CGRectMake(0.0f, [[[UIApplication sharedApplication] delegate] window].frame.size.height - _datePicker.frame.size.height - _dateToolbar.frame.size.height, _dateToolbar.frame.size.width, _dateToolbar.frame.size.height)];
                    
                    
                } completion:^(BOOL finished) {
                    
                }];
                
                break;
            }
            case ArtDetailRowLocationType:
            {
                _locationController = [[ArtLocationSelectionViewViewController alloc] initWithNibName:@"ArtLocationSelectionViewViewController" bundle:[NSBundle mainBundle] geotagLocation:_selectedLocation delegate:self currentLocationSelection:LocationSelectionPhotoLocation currentLocation:_currentLocation];
                
                [self.navigationController pushViewController:_locationController animated:YES];
                
                if (_selectedLocation) {
                    [_locationController setSelectedLocation:_selectedLocation];
                    [_locationController setSelection:LocationSelectionManualLocation];
                }
                else
                    [_locationController setSelectedLocation:_currentLocation];
                
                break;
            }
            case ArtDetailRowCategory:
            {
                SearchTableViewController *searchTableController = [[SearchTableViewController alloc] initWithStyle:UITableViewStylePlain];
                NSMutableArray *searchItems = [[NSMutableArray alloc] initWithCapacity:[[[AAAPIManager instance] categories] count]];
                for (NSString * cat in [[AAAPIManager instance] categories]) {
                    [searchItems addObject:[SearchItem searchItemWithTitle:cat subtitle:@""]];
                }
                
                [searchTableController setCreationEnabled:NO];
                [searchTableController setSearchItems:searchItems];
                [searchTableController setMultiSelectionEnabled:YES];
                [searchTableController setDelegate:self];
                [searchTableController.tableView setTag:20];
                
                //add the categories if they exist
                if ([_newArtDictionary objectForKey:@"categories"]) {
                    NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithArray:[_newArtDictionary objectForKey:@"categories"]];
                    [searchTableController setSelectedItems:selectedItems];
                }
                else if (_art.categories) {
                    NSMutableArray *selectedItems = [[NSMutableArray alloc] initWithCapacity:_art.categories.count];
                    for (Category *cat in _art.categories) {
                        [selectedItems addObject:cat.title];
                    }
                    [searchTableController setSelectedItems:selectedItems];
                }
                
                
                [self.navigationController pushViewController:searchTableController animated:YES];
                
                break;
            }
            default:
                break;
        }
    }
    else {
        switch (indexPath.row) {
            case ArtDetailRowComments:
            {
                if (_art.comments.count > 0) {
                    CommentsTableViewController *commentsVC = [[CommentsTableViewController alloc] initWithStyle:UITableViewStylePlain comments:[_art.comments allObjects]];
                    [self.navigationController pushViewController:commentsVC animated:YES];
                    
                    [Utilities trackEvent:@"Comments" action:@"CommentsViewed" label:_art.title];
                }
                
                break;
            }
            case ArtDetailRowAddComment:
            {
                AddCommentViewController *addVC = [[AddCommentViewController alloc] initWithNibName:@"AddCommentViewController" bundle:nil artSlug:_art.slug];
                [addVC setDelegate:self];
                [self.navigationController pushViewController:addVC animated:YES];
                break;
            }
            default:
                break;
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0f;
    
    if (_inEditMode) {
        
        height = 47.0f;
        
        switch (indexPath.row) {
            case ArtDetailRowBuffer:
            {
                height = 5.0f;
                break;
            }
            case ArtDetailRowPhotos:
            {
                height = _kPhotoScrollerHeight;
                break;
            }
            case ArtDetailRowDescription:
            {
                height = 123.0f;
                
                break;
            }
            case ArtDetailRowLocationDescription:
            {
                height = 123.0f;
                
                break;
            }
            case ArtDetailRowLocationMap:
            case ArtDetailRowComments:
            case ArtDetailRowAddComment:
            {
                height = 0.0f;
                break;
            }
            default:
                break;
        }
    }
    else {
        
        height = 25.0f;
        
        switch (indexPath.row) {
                
            case ArtDetailRowBuffer:
            {
                height = 5.0f;
                break;
            }
            case ArtDetailRowPhotos:
            {
                height = _kPhotoScrollerHeight;
                break;
            }
            case ArtDetailRowTitle:
            {
                if ([[_newArtDictionary objectForKey:@"title"] length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"title"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else if ([_art.title length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                
                break;
            }
            case ArtDetailRowYear:
            {
                if ([_newArtDictionary objectForKey:@"year"] && [_newArtDictionary objectForKey:@"year"] == [NSNumber numberWithInt:0]) {
                    height = 0.0f;
                }
                else if (_art.year == [NSNumber numberWithInt:0]) {
                    height = 0.0f;
                }
                
                break;
            }
            case ArtDetailRowLink:
            {
                if (_art.website.length == 0 && [[_newArtDictionary objectForKey:@"website"] length] == 0)
                    height = 0.0f;
                else if ([[_newArtDictionary objectForKey:@"website"] length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"website"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else if ([_art.website length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.website sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                
                break;
            }
            case ArtDetailRowArtist:
            {
                if (_art.artist.length == 0 && [[_newArtDictionary objectForKey:@"artist"] length] == 0)
                    height = 0.0f;
                else if ([[_newArtDictionary objectForKey:@"artist"] length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"artist"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else if ([_art.artist length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.artist sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                
                break;
            }
            case ArtDetailRowCommissioned:
            {
                if (_art.commissionedBy.length == 0 && [[_newArtDictionary objectForKey:@"commissioned_by"] length] == 0)
                    height = 0.0f;
                else {
                    if ([[_newArtDictionary objectForKey:@"commissioned_by"] length] > 0) {
                        CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                        CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"commissioned_by"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                        height = requiredLabelSize.height;
                    }
                    else if ([_art.commissionedBy length] > 0) {
                        CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                        CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.commissionedBy sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                        height = requiredLabelSize.height;
                    }
                }
                
                break;
            }
            case ArtDetailRowCategory:
            {
                if ([[[_newArtDictionary objectForKey:@"categories"] componentsJoinedByString:@", "] length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[[_newArtDictionary objectForKey:@"categories"] componentsJoinedByString:@", "] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else if ([_art.categoriesString length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.categoriesString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else {
                    height = 0;
                }
                
                break;
            }
            case ArtDetailRowDescription:
            {
                if ([[_newArtDictionary objectForKey:@"artDescription"] length] > 0) {
                    CGSize labelSize = CGSizeMake(300.0f, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"artDescription"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height + _kRowBufffer + 10.0f;
                    height += 30.0f;
                }
                else if ([_art.artDescription length] > 0) {
                    CGSize labelSize = CGSizeMake(300.0f, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.artDescription sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height + _kRowBufffer + 10.0f;
                    height += 30.0f;
                }
                else {
                    height = 0.0f;
                }
                
                break;
            }
            case ArtDetailRowLocationType:
            {
                if ([_locationString length] > 0) {
                    CGSize labelSize = CGSizeMake(_kRowTextFieldWidth, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_locationString sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height;
                }
                else {
                    height = 0.0f;
                }
                
                break;
            }
            case ArtDetailRowLocationDescription:
            {
                if ([[_newArtDictionary objectForKey:@"location_description"] length] > 0) {
                    CGSize labelSize = CGSizeMake(300.0f, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:[_newArtDictionary objectForKey:@"location_description"] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height + _kRowBufffer + 10.0f;
                }
                else if ([_art.locationDescription length] > 0) {
                    CGSize labelSize = CGSizeMake(300.0f, 10000.0f);
                    CGSize requiredLabelSize = [[Utilities instance] frameForText:_art.locationDescription sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0f] constrainedToSize:labelSize lineBreakMode:NSLineBreakByWordWrapping];
                    height = requiredLabelSize.height + _kRowBufffer + 10.0f;
                }
                else {
                    height = 0.0f;
                }
                
                break;
            }
            case ArtDetailRowLocationMap:
                height = _kMapHeight + (_kMapPadding * 2.0f);
                break;
            case ArtDetailRowComments:
            case ArtDetailRowAddComment:
                height = 45.0f;
                break;
            default:
                break;
        }
    }
    
    return (indexPath.row != ArtDetailRowBuffer && height != 0.0f && height < 25.0f) ? 25.0f : height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 35.0f;
}

#pragma mark - Image Scroll View
- (void)setupImages
{
	//loop through all the images and add an image view if it doesn't exist yet
	//update the url for each image view that doesn't have one yet
	//this method may be called multiple times as the flickr api returns info on each photo
    //insert the add button at the end of the scroll view
	PhotoImageButton *prevView = nil;
	NSUInteger totalPhotos = (_art && _art.photos != nil) ? [_art.photos count] + _userAddedImages.count : _userAddedImages.count;
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
			BOOL isPortrait = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]));
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
		PhotoImageButton *imageView = (PhotoImageButton *)[_photosScrollView viewWithTag:(10 + [[_art.photos sortedArrayUsingDescriptors:sortDescriptors] indexOfObject:photo])];
        if (!imageView) {
			imageView = [[PhotoImageButton alloc] initWithPlaceholderImage:nil];
			[imageView setTag:(10 + [[_art.photos sortedArrayUsingDescriptors:sortDescriptors] indexOfObject:photo])];
			[imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
			[imageView setClipsToBounds:YES];
			[imageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
			[imageView.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor];
			[imageView.layer setBorderWidth:6.0f];
            [imageView addTarget:self action:@selector(artButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[_photosScrollView addSubview:imageView];
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
			BOOL isPortrait = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]));
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
		PhotoImageButton *imageView = (PhotoImageButton *)[_photosScrollView viewWithTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
		if (!imageView) {
			imageView = [[PhotoImageButton alloc] initWithPlaceholderImage:nil];
			[imageView setTag:(_kUserAddedImageTagBase + [_userAddedImages indexOfObject:thisUserImage])];
			[imageView setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
			[imageView setClipsToBounds:YES];
			[imageView.imageView setContentMode:UIViewContentModeScaleAspectFill];
			[imageView setBackgroundColor:[UIColor lightGrayColor]];
			[imageView.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor];
			[imageView.layer setBorderWidth:6.0f];
            [imageView addTarget:self action:@selector(artButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
			[_photosScrollView addSubview:imageView];
            
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
        BOOL isPortrait = (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]));
        if (isPortrait) {
            prevOffset = _kPhotoInitialPaddingPortait;
        } else {
            prevOffset = _kPhotoInitialPaddingForOneLandScape;
        }
    }
    
    UIButton *addImgButton = (UIButton*)[_photosScrollView viewWithTag:_kAddImageButtonTag];
    if (!_inEditMode) {
        
        if (!addImgButton) {
            //setup the add image button
            addImgButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [addImgButton setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
            [addImgButton setImage:[UIImage imageNamed:@"uploadPhoto_noBg.png"] forState:UIControlStateNormal];
            [addImgButton.imageView setContentMode:UIViewContentModeCenter];
            [addImgButton.layer setBorderColor:[UIColor colorWithWhite:1.0f alpha:1.0f].CGColor];
            [addImgButton.layer setBorderWidth:6.0f];
            [addImgButton setTag:_kAddImageButtonTag];
            [addImgButton setBackgroundColor:[UIColor lightGrayColor]];
            [addImgButton addTarget:self action:@selector(addImageButtonTapped) forControlEvents:UIControlEventTouchUpInside];
            
            //adjust the button's autoresizing mask when there are fewer than 3 images so that it stays centered
            if (totalPhotos < 3) {
                [addImgButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
            }
            
            [_photosScrollView addSubview:addImgButton];
        }
        else {
            [addImgButton setFrame:CGRectMake(prevOffset, _kPhotoPadding, _kPhotoWidth, _kPhotoHeight)];
        }
        
        //set the content size
        [_photosScrollView setContentSize:CGSizeMake(addImgButton.frame.origin.x + addImgButton.frame.size.width + _kPhotoSpacing, _photosScrollView.frame.size.height)];
        [addImgButton setAlpha:1.0f];
    }
	else {
        //set the content size
        [_photosScrollView setContentSize:CGSizeMake(prevOffset + _kPhotoSpacing, _photosScrollView.frame.size.height)];
        [addImgButton setAlpha:0.0f];
    }
    
    _photosScrollView.backgroundColor = kDarkGray;
	
}

#pragma mark - PhotoImageViewDelegate
- (void) attributionButtonPressed:(id)sender withTitle:(NSString*)title andURL:(NSURL*)url
{
    //create request
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    //create webview
    UIWebView *webView = [[UIWebView alloc] init];
    [webView loadRequest:request];
    
    //create view controller
    UIViewController *containerViewController = [[UIViewController alloc] init];
    [containerViewController setView:webView];

    [self.navigationController pushViewController:containerViewController animated:YES];
    
}

#pragma mark - FlickrNameViewControllerDelegate
//submit flag
- (void)flickrNameViewControllerPressedSubmit:(id)controller
{
    NSString *handle = [[NSString alloc] initWithString:[[(FlickrNameViewController*)controller flickrHandleField] text]];
    [Utilities instance].photoAttributionText = handle;
    NSString *fUrlString = [[NSString alloc] initWithString:[[(FlickrNameViewController*)controller attributionURLField] text]];
    [Utilities instance].photoAttributionURL = fUrlString;
    [self userAddedImage:[(FlickrNameViewController*)controller image] withAttribution:YES];
    
    
    
    [[controller view] removeFromSuperview];
    [self.navigationItem.backBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    
    if (!_inEditMode)
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    
}

//dismiss flag controller
- (void) flickrNameViewControllerPressedCancel:(id)controller
{
    
    [self userAddedImage:[(FlickrNameViewController*)controller image] withAttribution:NO];
    
    [[(FlickrNameViewController*)controller view] removeFromSuperview];
    [self.navigationItem.backBarButtonItem setEnabled:YES];
    [self.navigationItem.leftBarButtonItem setEnabled:YES];
    
    if (!_inEditMode)
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //save flash mode in case it changed
        NSNumber *flashMode = [[NSNumber alloc] initWithInteger:picker.cameraFlashMode];
        [[Utilities instance] setFlashMode:flashMode];
    }
    
    //dismiss the picker view
    [self dismissViewControllerAnimated:YES completion:^{
        
        // Get the image from the result
        UIImage* image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
        
            
        _flickrNameController = [[FlickrNameViewController alloc] initWithNibName:@"FlickrNameViewController" bundle:[NSBundle mainBundle]];
        [_flickrNameController setImage:image];
        _flickrNameController.view.autoresizingMask = UIViewAutoresizingNone;
        _flickrNameController.delegate = self;
        
        [self.view addSubview:_flickrNameController.view];
        [self.navigationItem.backBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
    
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo {
    [self dismissViewControllerAnimated:YES completion:^{
        
        _flickrNameController = [[FlickrNameViewController alloc] initWithNibName:@"FlagViewController" bundle:[NSBundle mainBundle]];
        [_flickrNameController setImage:image];
        _flickrNameController.view.autoresizingMask = UIViewAutoresizingNone;
        _flickrNameController.delegate = self;
        
        [self.view addSubview:_flickrNameController.view];
        [self.navigationItem.backBarButtonItem setEnabled:NO];
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        [self.navigationItem.leftBarButtonItem setEnabled:NO];
        
    }];
}

- (void)userAddedImage:(UIImage*)image withAttribution:(BOOL)withAtt
{
    //increment the number of new images
    _addedImageCount += 1;
    
    NSString *attText, *attLink;
    
    if (withAtt) {
        attLink = [Utilities instance].photoAttributionURL;
        attText = [Utilities instance].photoAttributionText;
    }
    else {
        attLink = @"";
        attText = @"";
    }
    
    //upload image
    [[AAAPIManager instance] uploadImage:image forSlug:_art.slug withFlickrHandle:attText withPhotoAttributionURL:attLink withTarget:self callback:@selector(photoUploadCompleted:) failCallback:@selector(photoUploadFailed:)];
    
    [self showLoadingView:@"Uploading Photo\nPlease Wait..."];
    
    //reload the images to show the new image
    [self setupImages];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        //save flash mode in case it changed
        NSNumber *flashMode = [[NSNumber alloc] initWithInteger:picker.cameraFlashMode];
        [[Utilities instance] setFlashMode:flashMode];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //switch on the action sheet tag
    switch (actionSheet.tag) {
        case _kAddImageActionSheet:
        {
            
            //decide what the picker's source is
            switch (buttonIndex) {
                    
                case 0:
                {
                    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                    imgPicker.delegate = self;
                    imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                    imgPicker.cameraFlashMode = ([Utilities instance].flashMode) ? [[Utilities instance].flashMode integerValue] : UIImagePickerControllerCameraFlashModeAuto;
                    [self presentViewController:imgPicker animated:YES completion:^{
                        
                    }];
                    break;
                }
                case 1:
                {
                    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
                    imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    imgPicker.delegate = self;
                    [self presentViewController:imgPicker animated:YES completion:^{
                        
                    }];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case _kFlagActionSheet:
        {
            //break on cancel
            if (buttonIndex == 3) break;
            
            FlagViewController *flagController = [[FlagViewController alloc] initWithNibName:@"FlagViewController" bundle:nil];
            flagController.view.autoresizingMask = UIViewAutoresizingNone;
            flagController.delegate = self;
            
            [self presentViewController:flagController animated:YES completion:^{
            
                [self.navigationItem.backBarButtonItem setEnabled:NO];
                [self.navigationItem.rightBarButtonItem setEnabled:NO];
                [self.navigationItem.leftBarButtonItem setEnabled:NO];
                
            }];
            
            break;
        }
        default:
            break;
    }
    
	
}

#pragma mark - FlagViewControllerDelegate
//submit flag
- (void)flagViewControllerPressedSubmit:(id)controller
{
    [[AAAPIManager instance] submitFlagForSlug:_art.slug withText:[[(FlagViewController*)controller flagDescriptionTextview] text] target:self callback:@selector(flagSubmissionCompleted) failCallback:@selector(flagSubmissionFailed)];
    
}

//dismiss flag controller
- (void) flagViewControllerPressedCancel
{
    [self dismissViewControllerAnimated:YES completion:^{
        //    [[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)] removeFromSuperview];
        [self.navigationItem.backBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
    }];

}

//successful submission
- (void) flagSubmissionCompleted
{
    [self dismissViewControllerAnimated:YES completion:^{
        //    [[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)] removeFromSuperview];
        [self.navigationItem.backBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        UIAlertView *moderationComment = [[UIAlertView alloc] initWithTitle:@"Thanks for your note! Our moderators will take a look." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [moderationComment show];
        
        //track event
        [Utilities trackEvent:@"ArtFlagged" action:@"Flag" label:_art.title];
    }];

}

//unsuccessful submission
- (void) flagSubmissionFailed
{
    [self dismissViewControllerAnimated:YES completion:^{
        //[[self.view.subviews objectAtIndex:(self.view.subviews.count - 1)] removeFromSuperview];
        [self.navigationItem.backBarButtonItem setEnabled:YES];
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
        [self.navigationItem.leftBarButtonItem setEnabled:YES];
        
        UIAlertView *moderationComment = [[UIAlertView alloc] initWithTitle:@"Sorry! Something went wrong in the flag submission. Please try again." message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [moderationComment show];
    }];
}

#pragma mark - Text View Delegate

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSString* newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    if (textView == _descriptionTextView && ![textView.text isEqualToString:@"Share what you know about this art..."])
        [_newArtDictionary setObject:newText forKey:@"artDescription"];
    else if (textView == _locationDescriptionTextView && ![textView.text isEqualToString:@"Add extra location details..."])
        [_newArtDictionary setObject:newText forKey:@"location_description"];
    
    return YES;
}
- (void) textViewDidChange:(UITextView *)textView
{
    
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    
    if ([textView.text isEqualToString:@"Share what you know about this art..."] || [textView.text isEqualToString:@"Add extra location details..."]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    
    _textDoneButton.alpha = 1.0f;
    _submitEditButton.alpha = 0.0f;
    _cancelEditButton.alpha = 0.0f;


}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    _textDoneButton.alpha = 0.0f;
    _submitEditButton.alpha = 1.0f;
    _cancelEditButton.alpha = 1.0f;
    
    return YES;
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0) {
        if (textView == _descriptionTextView) {
            [textView setText:@"Share what you know about this art..."];
        }
        else {
            [textView setText:@"Add extra location details..."];
        }
        
        [textView setTextColor:[UIColor colorWithWhite:0.71f alpha:1.0f]];
    }
}

#pragma mark - Text Field Delegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [self findAndResignFirstResponder];
    return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString* newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    [self textFieldChanged:textField withText:newText];
    return YES;
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    
    [self textFieldChanged:textField];
}

- (void) textFieldChanged:(id)textField {
    
    if ([textField isKindOfClass:[UITextField class]]) {
        NSString *key = @"";
        
        if (textField == _artistTextField)
            key = @"artist";
        else if (textField == _titleTextField)
            key = @"title";
        else if (textField == _urlTextField)
            key = @"website";
        
        [_newArtDictionary setObject:[(UITextField*)textField text] forKey:key];
    }
    
    
}

- (void) textFieldChanged:(UITextField*)textField withText:(NSString*)text
{
    
    NSString *key = @"";
    
    if (textField == _artistTextField)
        key = @"artist";
    else if (textField == _titleTextField)
        key = @"title";
    else if (textField == _urlTextField)
        key = @"website";
    
    [_newArtDictionary setObject:text forKey:key];
    
    
}

#pragma mark - Picker Data Source
- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 114;
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    
    _yearFormatter = [[NSDateFormatter alloc] init];
    [_yearFormatter setDateFormat:@"yyyy"];
    NSString *yearString = [_yearFormatter stringFromDate:[NSDate date]];
    int currentYear = [yearString intValue];
    
    NSNumber *yearNumber = [NSNumber numberWithUnsignedLong:currentYear-row];
    title = [yearNumber stringValue];
    
    return title;
}

#pragma mark - Picker View Delegate
- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    _yearFormatter = [[NSDateFormatter alloc] init];
    [_yearFormatter setDateFormat:@"yyyy"];
    NSString *yearString = [_yearFormatter stringFromDate:[NSDate date]];
    int currentYear = [yearString intValue];
    
    NSNumber *yearNumber = [NSNumber numberWithUnsignedLong:currentYear-row];
    _yearString = [[NSString alloc] initWithString:[yearNumber stringValue]];
    
    [self.tableView reloadData];
}

#pragma mark - Search Table Delegate
- (void) searchTableViewController:(SearchTableViewController *)searchController didFinishWithSelectedItems:(NSArray *)items
{
    if (searchController.tableView.tag == 10) {
        if (items.count > 0) {
            if ([[[items objectAtIndex:0] title] isEqualToString:@"None"]) {
                [_newArtDictionary removeObjectForKey:@"commissioned_by"];
            }
            else {
                NSString *com = [[NSString alloc] initWithString:[[items objectAtIndex:0] title]];
                [_newArtDictionary setObject:com forKey:@"commissioned_by"];
            }
        }
    }
    else {
        //reset and add the cateogries to the new art
        NSMutableArray *categories = [[NSMutableArray alloc] init];
        [_newArtDictionary setObject:categories forKey:@"categories"];
        
        for (SearchItem *thisItem in items) {
            
            if ([thisItem isKindOfClass:[SearchItem class]]) {
                
                if (![[_newArtDictionary objectForKey:@"categories"] containsObject:thisItem.title]) {
                    [[_newArtDictionary objectForKey:@"categories"] addObject:thisItem.title];
                }
            }
            else if ([thisItem isKindOfClass:[NSString class]]) {
                if (![[_newArtDictionary objectForKey:@"categories"] containsObject:thisItem]) {
                    [[_newArtDictionary objectForKey:@"categories"] addObject:thisItem];
                }
            }
        }
    
    }
    
    [self.tableView reloadData];
    
    [self.navigationController popToViewController:self animated:YES];
    
    
}

#pragma mark - ArtLocationSelectionDelegate
- (void) locationSelectionViewController:(ArtLocationSelectionViewViewController *)controller selected:(LocationSelection)selection
{
    _selectedLocation = [[CLLocation alloc] initWithLatitude:controller.selectedLocation.coordinate.latitude longitude:controller.selectedLocation.coordinate.longitude];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:_selectedLocation.coordinate.latitude longitude:_selectedLocation.coordinate.longitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            DebugLog(@"Error durring reverse geocode");
        }
        
        if (placemarks.count > 0) {
            _locationString = [[placemarks objectAtIndex:0] name];
            [self.tableView reloadData];
            
            //create an annotation, add it to the map, and store it in the array
            [_mapView removeAnnotations:_mapView.annotations];
            ArtAnnotation *annotation = [[ArtAnnotation alloc] initWithCoordinate:_selectedLocation.coordinate title:@"" subtitle:@""];
            [_mapView addAnnotation:annotation];
        }
        
    }];
    
//    switch (selection) {
//        case LocationSelectionUserLocation:
//        {
//            _selectedLocation = [[CLLocation alloc] initWithLatitude:_currentLocation.coordinate.latitude longitude:_currentLocation.coordinate.longitude];
//            
//            //add the annotation for the art
//            if (_selectedLocation.coordinate.latitude && _selectedLocation.coordinate.longitude) {
//                
//                [_mapView removeAnnotations:_mapView.annotations];
//                
//                //setup the coordinate
//                CLLocationCoordinate2D artLocation;
//                artLocation.latitude = _selectedLocation.coordinate.latitude;
//                artLocation.longitude = _selectedLocation.coordinate.longitude;
//                
//                //create an annotation, add it to the map, and store it in the array
//                ArtAnnotation *annotation = [[ArtAnnotation alloc] initWithCoordinate:artLocation title:_art.title subtitle:_art.artist];
//                [_mapView addAnnotation:annotation];
//                [annotation release];
//                
//                CLGeocoder *geocoder = [[CLGeocoder alloc] init];
//                CLLocation *location = [[CLLocation alloc] initWithLatitude:artLocation.latitude longitude:artLocation.longitude];
//                [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
//                    if (error){
//                        DebugLog(@"Error durring reverse geocode");
//                    }
//                    
//                    if (placemarks.count > 0) {
//                        _locationString = [[NSString alloc] initWithString:[[placemarks objectAtIndex:0] name]];
//                        [self.tableView reloadData];
//                    }
//                    
//                }];
//                
//            }
//            
//            break;
//        }
//        default:
//            break;
//    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Photo Upload Callback Methods

- (void)photoUploadCompleted:(NSDictionary*)responseDict
{
    if ([responseDict objectForKey:@"slug"]) {
        
        //track event
        [Utilities trackEvent:@"PhotoUploaded" action:@"Photo" label:_art.title];
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            [Art MR_importFromObject:responseDict inContext:localContext];
        } completion:^(BOOL success, NSError *error) {
            
            
            [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                
                Art *artRecord = [Art MR_findFirstByAttribute:@"artID" withValue:[responseDict objectForKey:@"slug"] inContext:localContext];
                
                //add categories
                if ([[responseDict objectForKey:@"category"] isKindOfClass:[NSArray class]]) {
                    
                    for (NSString *thisCatTitle in [responseDict objectForKey:@"category"]) {
                        
                        Category *catObject = [Category MR_findFirstByAttribute:@"categoryID" withValue:thisCatTitle];
                        if (catObject) {
                            [artRecord addCategoriesObject:catObject];
                        }
                        
                    }
                    
                }
                
                //add photos
                if ([[responseDict objectForKey:@"photos"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *photoObjects = [Photo MR_importFromArray:[responseDict objectForKey:@"photos"] inContext:localContext];
                    NSSet *photosSet = [[NSSet alloc] initWithArray:photoObjects];
                    [artRecord addPhotos:photosSet];
                    
                    
                }
                
                //add comments
                if ([[responseDict objectForKey:@"comments"] isKindOfClass:[NSArray class]]) {
                    
                    NSArray *commentObjects = [Comment MR_importFromArray:[responseDict objectForKey:@"comments"] inContext:localContext];
                    NSSet *commentSet = [[NSSet alloc] initWithArray:commentObjects];
                    [artRecord addComments:commentSet];
                    
                    
                }
                
            } completion:^(BOOL success, NSError *error) {
                _art = [Art MR_findFirstByAttribute:@"slug" withValue:[responseDict objectForKey:@"slug"]];
            }];
            
            
        }];
        
        //parse the art object returned and update this controller instance's art
//        [[AAAPIManager managedObjectContext] lock];
        //_art = [[ArtParser artForDict:responseDict inContext:[AAAPIManager managedObjectContext]] retain];
//        _art = [ArtParser artForDict:responseDict inContext:[AAAPIManager managedObjectContext]];

//        [[AAAPIManager managedObjectContext] unlock];
        
        //merge context
//        [[AAAPIManager instance] performSelectorOnMainThread:@selector(mergeChanges:) withObject:[NSNotification notificationWithName:NSManagedObjectContextDidSaveNotification object:[AAAPIManager managedObjectContext]] waitUntilDone:YES];
    }
    else {
        [self photoUploadFailed:responseDict];
        return;
    }
    
    _addedImageCount -= 1;
    
    //if there are no more photo upload requests processing
    //switch out of edit mode
    if (_addedImageCount == 0) {
        
        //dismiss the alert view
        [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
        
        //reload the map view so the updated/new art is there
//        ArtAroundAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
//        [appDelegate saveContext];
        
        //clear the user added images array
        [_userAddedImages removeAllObjects];
    }
    
    [self setupImages];
    
}

- (void)photoUploadFailed:(NSDictionary*)responseDict
{
    _addedImageCount -= 1;
    
    //dismiss the alert view
    [_loadingAlertView dismissWithClickedButtonIndex:0 animated:YES];
    
    
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
	[Utilities zoomToFitMapAnnotations:mapView];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    //if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
    
    //new single pinart
    NSString *reuseIdentifier = @"art";
    UIImage *pinImage = [UIImage imageNamed:@"PinArt.png"];

    //setup the annotation view
    ArtAnnotationView *pin = [[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    [pin setImage:pinImage];
    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
    [pin setCanShowCallout:NO];
    
    return pin;
}

#pragma mark - Comment Delegate
- (void) commentSubmitted
{

    [self.navigationController popToViewController:self animated:YES];
    
    //get the comments for this art
    [[AAAPIManager instance] downloadArtForSlug:_art.slug target:self callback:@selector(artDownloadComplete) forceDownload:YES];
    
}

#pragma mark - Share

- (void)shareButtonTapped
{
    //track event
    [Utilities trackEvent:@"ShareButtonPressed" action:@"Share" label:_art.title];
    
    if ([Utilities is6OrHigher]) {
        
        //get the share title and url
        NSString *shareTitle = [self shareMessage];
        NSArray *shareItems = nil;
        if (shareTitle) {
            shareItems = [NSArray arrayWithObjects:shareTitle, nil];
        }
        
        //show the share view
        if (shareItems) {
            UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:shareItems applicationActivities:nil];
            [activityController setExcludedActivityTypes:[NSArray arrayWithObject:UIActivityTypeSaveToCameraRoll]];
            [self presentViewController:activityController animated:YES completion:nil];
        }
        
        
    }

}

- (NSString *)shareMessage
{
	return [NSString stringWithFormat:@"Check out this artwork on ArtAround: %@", [self shareURL]];
}

- (NSString *)shareURL
{
	return [NSString stringWithFormat:@"http://theartaround.us/arts/%@", _art.slug];
}


@end
