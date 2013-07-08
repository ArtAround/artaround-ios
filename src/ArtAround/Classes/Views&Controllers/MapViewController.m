//
//  MapViewController.m
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "MapViewController.h"
#import "MapView.h"
#import "FilterViewController.h"
#import "AAAPIManager.h"
#import "Art.h"
#import "ArtAnnotation.h"
#import "ArtAnnotationView.h"
#import "CalloutAnnotationView.h"
#import "Category.h"
#import "DetailViewController.h"
#import "AddDetailViewController.h"
#import "QuartzCore/CALayer.h"
#import "AddArtViewController.h"

static const int _kAnnotationLimit = 9999;

@interface MapViewController (private)
-(void)artUpdated;
-(void)filterButtonTapped;
-(void)addButtonTapped;
-(void)favoritesButtonTapped;
-(void)closeButtonPressed;
@end

@implementation MapViewController
@synthesize mapView = _mapView, callout = _callout, listViewController = _listViewController, showFavorites = _showFavorites;

#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        
		//initialize arrays
		_items = [[NSMutableArray alloc] init];
		_annotations = [[NSMutableArray alloc] init];

        //initialize list view controller
        _listViewController = [[ListViewController alloc] initWithStyle:UITableViewStylePlain items:_items];
        
        //init favs flag
        _showFavorites = NO;
        
        //init showingMap
        _showingMap = YES;
        
        //init found user
        _foundUser = NO;
		
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

}

- (void)loadView
{
	[super loadView];
    
	//the map needs to be refreshed
	_mapNeedsRefresh = YES;
    
    
    //add button
    UIBarButtonItem *addButton= [[UIBarButtonItem alloc] initWithTitle:@"Add Art" style:UIBarButtonItemStylePlain target:self action:@selector(addButtonTapped)];
    
    //refresh button
    UIImage *mapButtonImage = [UIImage imageNamed:@"MapButton.png"];
    UIImage *listButtonImage = [UIImage imageNamed:@"ListButton.png"];
    _listButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapButtonImage.size.width, mapButtonImage.size.height)];
    [_listButton setImage:listButtonImage];
    _mapButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, listButtonImage.size.width, listButtonImage.size.height)];
    [_mapButton setImage:mapButtonImage];
    _listButton.backgroundColor = [UIColor clearColor];
    _mapButton.backgroundColor = [UIColor clearColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(flipMap) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, 30, 30);    
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mapButtonImage.size.width, mapButtonImage.size.height)];
    buttonView.backgroundColor = [UIColor clearColor];

    [buttonView addSubview:_mapButton];
    [buttonView addSubview:_listButton];
    [buttonView addSubview:btn];
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [flipButton setTarget:self];
    [flipButton setAction:@selector(flipMap)];
    
    UIBarButtonItem *refreshButton= [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(flipMap)];
    
    
    [self.navigationItem setLeftBarButtonItem:addButton];
    [self.navigationItem setRightBarButtonItem:flipButton];

    
    //setup the list view
    [_listViewController.tableView setFrame:CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height)];
    _listViewController.delegate = self;
    [_listViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [_listViewController.favoriteButton setSelected:_showFavorites];    
    [self.view addSubview:_listViewController.tableView];	
	
    //setup the map view
	MapView *aMapView = [[MapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height)];
	[self setMapView:aMapView];
	[self.mapView.map setDelegate:self];
    [self.mapView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.view addSubview:self.mapView];
	[aMapView release];

    
	//default to dc map
	MKCoordinateSpan spanDC = MKCoordinateSpanMake(40.0, 40.0);
	CLLocationCoordinate2D centerDC;
	centerDC.latitude = 38.895;
	centerDC.longitude = -77.022;
	[self.mapView.map setRegion:[self.mapView.map regionThatFits:MKCoordinateRegionMake(CLLocationCoordinate2DMake(39.707187, -97.734375), spanDC)]];
	[self.mapView.map setShowsUserLocation:YES];
    
	//setup button actions
	[self.mapView.favoritesButton addTarget:self action:@selector(favoritesButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.filterButton addTarget:self action:@selector(filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.locateButton addTarget:self action:@selector(locateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	
    //inital load view
    if (![[Utilities instance] hasLoadedBefore]) {
        _initialLoadView = [[UIView alloc] initWithFrame:CGRectInset(_mapView.frame, 20, 50)];
        _initialLoadView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
        _initialLoadView.alpha = 0;
        _initialLoadView.center = CGPointMake(_initialLoadView.center.x, _initialLoadView.center.y - 20);
        _initialLoadView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
        _initialLoadView.layer.shadowColor = [UIColor darkGrayColor].CGColor;
        _initialLoadView.layer.shadowRadius = 3.0f;
        _initialLoadView.layer.shadowOffset = CGSizeMake(0, 1.0);
        _initialLoadView.layer.shadowOpacity = 0.9f;
        
        UILabel *topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, _initialLoadView.frame.size.width, 20)];
        [topLabel setText:@"A hint before you start..."];
        [topLabel setTextAlignment:UITextAlignmentCenter];
        [topLabel setBackgroundColor:[UIColor clearColor]];
        [topLabel setFont:[UIFont fontWithName:@"Georgia-BoldItalic" size:15]];
        [topLabel setTextColor:kFontColorDarkBrown];
        [_initialLoadView addSubview:topLabel];
        [topLabel release];

        UILabel *secondLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 24, _initialLoadView.frame.size.width, 14)];
        [secondLabel setText:@"(We'll only show this once. We promise.)"];
        [secondLabel setBackgroundColor:[UIColor clearColor]];
        [secondLabel setTextAlignment:UITextAlignmentCenter];
        [secondLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10]];
        [secondLabel setTextColor:kFontColorDarkBrown];
        [_initialLoadView addSubview:secondLabel];
        [secondLabel release]; 
        
        
        float yVal = 44;
        for (int index = 0; index < 4; index++) {

            //add divider
            UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, yVal, _initialLoadView.frame.size.width, 1)];
            UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, 1+yVal, _initialLoadView.frame.size.width, 1)];
            line1.backgroundColor = [UIColor whiteColor];
            line2.backgroundColor = kBGlightBrown;
            line1.alpha = 0.2;
            line2.alpha = 0.2;
            [_initialLoadView addSubview:line1];
            [_initialLoadView addSubview:line2];
            [line1 release];
            [line2 release];
            
            if (index < 3) {
                
                NSString *text1, *text2, *img1, *img2;
                text1 = @"Art";
                text2 = @"Art";
                img1 = @"PinArt.png";
                img2 = @"PinArt.png";
                
                
                /*
                switch (index) {
                    case 0:
                        text1 = @"Art";
                        text2 = @"Popular Art";
                        img1 = @"PinArt.png";
                        img2 = @"PinArtPressed.png";
                        break;
                        
                    case 1:
                        text1 = @"Venue";
                        text2 = @"Popular Venue";
                        img1 = @"PinVenue.png";
                        img2 = @"PinVenuePressed.png";
                        break;
                        
                    case 2:
                        text1 = @"Event";
                        text2 = @"Popular Event";
                        img1 = @"PinEvent.png";
                        img2 = @"PinEventPressed.png";
                        break;                    
                    default:
                        break;
                }*/
                
                float sectionCenter = yVal + 38;
                
                //add pins
                UIImageView *pin1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img1]];
                [pin1 setCenter:CGPointMake(35, sectionCenter)];
                [_initialLoadView addSubview:pin1];
                UIImageView *pin2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:img2]];
                [pin2 setCenter:CGPointMake(135, sectionCenter)];
                [_initialLoadView addSubview:pin2];
                [pin1 release];
                [pin2 release];
                
                //add labels
                UILabel *regular = [[UILabel alloc] initWithFrame:CGRectMake(pin1.image.size.width + pin1.frame.origin.x, 0, 60, 20)];
                UILabel *popular = [[UILabel alloc] initWithFrame:CGRectMake(pin2.image.size.width + pin2.frame.origin.x, 0, 160, 20)];
                [regular setCenter:CGPointMake(regular.center.x, sectionCenter)];
                [popular setCenter:CGPointMake(popular.center.x, sectionCenter)];
                [regular setFont:[UIFont fontWithName:@"Georgia-BoldItalic" size:14.0f]];
                [popular setFont:[UIFont fontWithName:@"Georgia-BoldItalic" size:14.0f]];
                [regular setBackgroundColor:[UIColor clearColor]];
                [popular setBackgroundColor:[UIColor clearColor]];
                [regular setText:text1];
                [popular setText:text2];
                [regular setTextColor:kFontColorDarkBrown];
                [popular setTextColor:kFontColorDarkBrown]; 
                [_initialLoadView addSubview:regular];
                [_initialLoadView addSubview:popular];
                [regular release];
                [popular release];
                
                
            }
            
            yVal += 76;
        }
        
        UIButton *closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, _initialLoadView.frame.size.height - 46, _initialLoadView.frame.size.width, 48)];
        [closeButton addTarget:self action:@selector(closeButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [closeButton setTitle:@"LET ME SEE THE ART!" forState:UIControlStateNormal];
        closeButton.titleLabel.font = [UIFont fontWithName:@"Verdana-Bold" size:16.0];
        [closeButton setTitleColor:[UIColor colorWithRed:(196.0/255.0) green:(199.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateNormal];
        [closeButton setTitleColor:[UIColor colorWithRed:(170.0/255.0) green:(173.0/255.0) blue:(47.0/255.0) alpha:1] forState:UIControlStateHighlighted];
        [closeButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        [_initialLoadView addSubview:closeButton];
        [closeButton release];
        
        [self.view addSubview:_initialLoadView];
    }
    
    
    //bg color
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
	[self setMapView:nil];
	[self.navigationController popToRootViewControllerAnimated:NO];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	//show the logo view
	[Utilities showLogoView:YES inNavigationBar:self.navigationController.navigationBar];
}



- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//clear out the navigation controller possibly set by another view controller
	[self.navigationController setDelegate:nil];
	
    if (_initialLoadView) {
        [UIView animateWithDuration:0.3 animations:^{
            [_initialLoadView setAlpha:1.0];
        }];
    }
    
	//update the map if needed
	if (_mapNeedsRefresh) {
		[self refreshArt];
		[self updateArt];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
//	return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _listViewController.view.frame = CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height);
    _mapView.frame = CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height);
}

- (void)dealloc
{
	[_items release];
	[_annotations release];
	[self.mapView.map setDelegate:nil];
	[self setMapView:nil];
	[self setCallout:nil];
	[super dealloc];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	//decide what to do based on the button index
	//just one button for now (plus cancel), but expect more later
	switch (buttonIndex) {
			
		//show the art around web set
		case 0:
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://theartaround.us/"]];
			break;
			
		default:
			break;
	}
}

#pragma mark - Button Actions
-(void)closeButtonPressed 
{
    
    float scale = 0.1f;
    [_initialLoadView setAlpha:0.0];
    [_initialLoadView setTransform:CGAffineTransformMakeScale(scale, scale)];
    [_initialLoadView release];
    _initialLoadView = nil;
    
    [[Utilities instance] setHasLoadedBefore:YES];
    
}

-(void)addButtonTapped 
{
    //create the add controller
    AddArtViewController *detailViewController = [[AddArtViewController alloc] initWithNibName:@"AddArtViewController" bundle:nil];
    detailViewController.currentLocation = self.mapView.map.userLocation.location;
    [self.navigationController pushViewController:detailViewController animated:YES];
    
    
    //set the location coord to the user's location
    //detailViewController.currentLocation = self.mapView.map.userLocation.location;
//    [detailViewController release];
}

- (void)favoritesButtonTapped
{
    //reverser favs flag
	_showFavorites = !_showFavorites;
    
    //update the button image
    [self.mapView.favoritesButton setSelected:_showFavorites];
    [_listViewController.favoriteButton setSelected:_showFavorites];
    
    //update art
    [self updateArt];
}

-(void)filterButtonTapped
{
	//create a top level filter controller and push it to the nav controller
	FilterViewController *filterController = [[FilterViewController alloc] init];
	[self.navigationController pushViewController:filterController animated:YES];
	[filterController release];
}

- (void)locateButtonTapped
{
	//if the user location hasn't been found yet, an expection will be thrown
	@try {
		
		//get the user location
		CLLocationCoordinate2D location = self.mapView.map.userLocation.coordinate;
		
		//set the span
		MKCoordinateSpan span;
		span.latitudeDelta = 0.05f;
		span.longitudeDelta = 0.05f;
		
		//set the region
		MKCoordinateRegion region;
		region.span=span;
		region.center=location;
		
		//zoom/pan the map on the user location
		[self.mapView.map setRegion:region animated:TRUE];
		[self.mapView.map regionThatFits:region];
		
	}
	@catch (NSException *exception) {
		
		//there was a problem setting zooming the map on the user
		//their location probably hasn't been found yet because the app just loaded
		//show an alert to let them know to hold their horses
		UIAlertView *locateAlert = [[UIAlertView alloc] initWithTitle:@"Unable To Find You" message:@"There was a problem finding your location. Please try again." delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
		[locateAlert show];
		[locateAlert release];
		
	}
}

- (void)calloutTapped
{
	//make sure there is an item to select in the array
	//don't add another detail controller if one is already displayed
	if ([_items count] > self.callout.tag && [self.navigationController.topViewController class] != [DetailViewController class]) {
		
		//get the selected art piece
		Art *selectedArt = [_items objectAtIndex:self.callout.tag];
		
        //pass it along to a new detail controller and push it the navigation controller
		DetailViewController *detailController = [[DetailViewController alloc] init];
		[self.navigationController pushViewController:detailController animated:YES];
        
        //set the location coord to the user's location and the art selected
        detailController.currentLocation = self.mapView.map.userLocation.location;
        [detailController setArt:selectedArt withTemplate:nil];
        
		[detailController release];
		
	}
}

#pragma mark - Update Art

- (void)flipMap 
{
    
    if (_showingMap) {
        [UIView transitionFromView:self.mapView toView:_listViewController.tableView duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        [UIView transitionFromView:_listButton toView:_mapButton duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        
        [_listViewController.favoriteButton setSelected:_showFavorites];
    }
    else {
        [UIView transitionFromView:_listViewController.tableView toView:self.mapView duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        [UIView transitionFromView:_mapButton  toView:_listButton duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];        
    }
    
    _showingMap = !_showingMap;
    
}

//refersh art
- (void)refreshArt
{
    [[AAAPIManager instance] downloadAllArtWithTarget:self callback:@selector(artUpdated) forceDownload:YES];
    
}

//called by AAAPIManager when new art is downloaded
- (void)artUpdated
{
	_mapNeedsRefresh = YES;
	[self updateArt];
}

//queries core data for art and adds them to the map
- (void)updateArt
{
    [self updateAndShowArt:nil];
}


//should update art and then focus on specified art
-(void)updateAndShowArt:(Art*)showArt
{
	//get art from core data
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Art" inManagedObjectContext:[AAAPIManager managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:_kAnnotationLimit];
	
    //turn the header on or off
    if ([Utilities instance].selectedFilterType == FilterTypeNone && !_showFavorites)
        self.mapView.headerView.alpha = 0;
    else {
        self.mapView.headerView.alpha = 1;
        
        if ([Utilities instance].selectedFilterType != FilterTypeNone && _showFavorites)
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Filtered & Favorites"];
        else if ([Utilities instance].selectedFilterType == FilterTypeNone && _showFavorites)
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Favorites"];
        else
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Filtered"];
    }
    
	//setup the proper delegate for the selected filter
	switch ([Utilities instance].selectedFilterType) {
			
        case FilterTypeArtist: {
			NSArray *artists = [[Utilities instance] getFiltersForFilterType:FilterTypeArtist];
			if (artists) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:(_showFavorites) ? @"favorite == TRUE AND artist IN %@" : @"artist IN %@", artists]];
			}
            
			break;
		}
		case FilterTypeTitle: {
			NSArray *titles = [[Utilities instance] getFiltersForFilterType:FilterTypeTitle];
			if (titles) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:(_showFavorites) ? @"favorite == TRUE AND title IN %@" : @"title IN %@", titles]];
			}
            
			break;
		}
		case FilterTypeCategory: {
			NSArray *categoriesTitles = [[Utilities instance] getFiltersForFilterType:FilterTypeCategory];
			if (categoriesTitles) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:(_showFavorites) ? @"favorite == TRUE AND category.title IN %@" : @"category.title IN %@", categoriesTitles]];
			}
            
            break;
		}
		default: {
            
            if (_showFavorites) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite == TRUE"]];
			}
            
			break;
        }
	}
	
	//clear out the art and annotation arrays
	[_mapView.map performSelectorOnMainThread:@selector(removeAnnotations:) withObject:_annotations waitUntilDone:YES];
	[_annotations removeAllObjects];
	[_items removeAllObjects];
	
	//fetch art
	//execute fetch request
	NSError *error = nil;
	NSArray *queryItems = [[AAAPIManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
	[_items addObjectsFromArray:queryItems];
    
    CLLocation *currentLoc = [[CLLocation alloc] initWithLatitude:self.mapView.map.userLocation.coordinate.latitude longitude:self.mapView.map.userLocation.coordinate.longitude];
    
    //sort items by distance
    for (Art *thisArt in _items) {
        CLLocation *thisLoc = [[CLLocation alloc] initWithLatitude:[thisArt.latitude doubleValue] longitude:[thisArt.longitude doubleValue]];
        [thisArt setDistance:[NSNumber numberWithDouble:([thisLoc distanceFromLocation:currentLoc] / 1609.3)]];
    
    }
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES];
    [_items sortUsingDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
	
    //reset the list view
    [_listViewController setItems:_items];
    
	//release fetch request
	[fetchRequest release];
	
	//check for errors
	if (!_items || error) {
		return;
	}
	
    //look for prevously added art
    NSString *artSlug = (showArt) ? [showArt slug] : nil;
    int annotationIndex = -1;
    
	//add annotations
	for (int i = 0; i < [_items count]; i++) {
		
		//add the annotation for the art
		Art *art = [_items objectAtIndex:i];
		if ([art.latitude doubleValue] && [art.longitude doubleValue]) {
			
			//setup the coordinate
			CLLocationCoordinate2D artLocation;
			artLocation.latitude = [art.latitude doubleValue];
			artLocation.longitude = [art.longitude doubleValue];
			
			//create an annotation, add it to the map, and store it in the array
			ArtAnnotation *annotation = [[ArtAnnotation alloc] initWithCoordinate:artLocation title:art.title subtitle:art.artist];
			annotation.index = i; //used when tapping the callout accessory button
			[_annotations addObject:annotation];
			[annotation release];
			
		}
        
        if (art.slug == artSlug)
            annotationIndex = i;
		
	}
	
	//add annotations
	[_mapView.map performSelectorOnMainThread:@selector(addAnnotations:) withObject:_annotations waitUntilDone:YES];
	_mapNeedsRefresh = NO;
    
    
    if (_showingMap && annotationIndex != -1) {
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.index == %i", annotationIndex];
        NSArray *filteredAnnotations = [_annotations filteredArrayUsingPredicate:predicate];
        
        if (filteredAnnotations.count > 0)
            [self mapView:_mapView.map didSelectAnnotationView:[_mapView.map viewForAnnotation:[filteredAnnotations objectAtIndex:0]]]; 
    }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	//if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	
	if ([annotation isKindOfClass:[ArtAnnotation class]]) {
	
		//setup the annotation view for the annotation
		int index = [(ArtAnnotation *)annotation index];
		if ([_items count] > index) {
			
			//get the art piece for this annotation view
			Art *art = [_items objectAtIndex:index];
			
			//setup the pin image and reuse identifier
			NSString *title = [[art categoriesString] lowercaseString];
			NSString *reuseIdentifier = nil;
			UIImage *pinImage = nil;
			
            //new single pinart
            reuseIdentifier = @"art";
            pinImage = [UIImage imageNamed:@"PinArt.png"];
            
			//setup the annotation view
			ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
			[pin setImage:pinImage];
			[pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
			[pin setCanShowCallout:NO];
			[pin setTag:index];
			
			//return the annotion view
			return pin;
			
		}
		
	} else if ([annotation isKindOfClass:[CalloutAnnotationView class]]) {
		
		//center the map on the callout annotation
		//return the callout annotation view
		if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
			
			//landscape
			//exactly center on landscape has the callout off the screen, gotta take an extra step to show it
			[mapView setCenterCoordinate:[(CalloutAnnotationView *)annotation coordinate] animated:NO];
			CGPoint point = [mapView convertCoordinate:[(CalloutAnnotationView *)annotation coordinate] toPointToView:mapView];
			CLLocationCoordinate2D coordinate = [mapView convertPoint:CGPointMake(mapView.frame.size.width / 2, point.y - 70.0) toCoordinateFromView:mapView];
			[mapView setCenterCoordinate:coordinate animated:YES];
			
			
		} else {
			
			//portrait
			[mapView setCenterCoordinate:[(CalloutAnnotationView *)annotation coordinate] animated:YES];
			
		}
		return (CalloutAnnotationView *)annotation;
		
	}

	//something must have gone wrong
	return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
	//if it's the user location, just return nil.
	if ([view.annotation isKindOfClass:[MKUserLocation class]]) {
		return;
	}
	
	if ([view isKindOfClass:[ArtAnnotationView class]] && (view.annotation.coordinate.latitude != self.callout.coordinate.latitude || view.annotation.coordinate.longitude != self.callout.coordinate.longitude)) {
		
        
        
		//create the callout if it doesn't exist yet
		if (!self.callout) {
			
			//setup the callout view
			CalloutAnnotationView *aCallout = [[CalloutAnnotationView alloc] initWithCoordinate:[(ArtAnnotation *)view.annotation coordinate] frame:CGRectMake(0.0f, 0.0f, 320.0f, 335.0f)];
			[aCallout setMapView:self.mapView.map];			
			[aCallout.button addTarget:self action:@selector(calloutTapped) forControlEvents:UIControlEventTouchUpInside];
			[self setCallout:aCallout];
			[aCallout release];
			
		} else {
			
			//update the coordinate
			[self.callout setCoordinate:[(ArtAnnotation *)view.annotation coordinate]];
			
		}
		
		//first move the annotation, set the new art, then add it to the map
		//removing it ensures it is on top of all other annotation
		if ([_items count] > view.tag) {
			Art *selectedArt = [_items objectAtIndex:view.tag];
			[self.callout setTag:view.tag];
			[self.mapView.map removeAnnotation:self.callout];
			[self.callout setParentAnnotationView:(ArtAnnotationView *)view];
			[self.callout prepareForReuse];
			[self.callout setArt:selectedArt];
			[self.mapView.map addAnnotation:self.callout];
            

		}
		
	} else if (self.callout && self.callout.parentAnnotationView == view) {
		
		//the callout was tapped
		//this is primarily for older devices such as the iphone 3g which seems delayed in responding to the typical target for UIControlEventTouchUpInside
		//calloutTapped checks to be sure multiple controllers aren't pushed to the navigation stack
		[self calloutTapped];
		
	}
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
	//if this is the annotation that was showing the callout, remove the callout 
	ArtAnnotationView *annotationView = (ArtAnnotationView *)view;
	if ([annotationView isKindOfClass:[ArtAnnotationView class]] && annotationView.annotation.coordinate.latitude == self.callout.coordinate.latitude && annotationView.annotation.coordinate.longitude == self.callout.coordinate.longitude && !annotationView.preventSelectionChange) {
		[self.mapView.map removeAnnotation:self.callout];
        
	}
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
   
    if (!_foundUser && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
        [self.mapView.map setRegion:[self.mapView.map regionThatFits:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.09, 0.09))] animated:YES];
        _foundUser = YES;
    }
    
}

#pragma mark - Listview delegate
- (void)selectedArtAtIndex:(int)index
{

    //get the selected art piece
    Art *selectedArt = [_items objectAtIndex:index];
    
    //pass it along to a new detail controller and push it the navigation controller
    DetailViewController *detailController = [[DetailViewController alloc] init];
    [self.navigationController pushViewController:detailController animated:YES];
    
    //set the location coord to the user's location and the art selected
    detailController.currentLocation = self.mapView.map.userLocation.location;
    [detailController setArt:selectedArt withTemplate:nil];
    
    [detailController release];
    
}

- (NSDictionary*) currentLocation
{

    NSDictionary *locDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:self.mapView.map.userLocation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:self.mapView.map.userLocation.coordinate.longitude], @"long", nil];
    return locDict;
    
}

- (void) listViewFilterButtonPressed {
    [self filterButtonTapped];
}

- (void) listViewFavoritesButtonPressed {
    [self favoritesButtonTapped];
}

@end
