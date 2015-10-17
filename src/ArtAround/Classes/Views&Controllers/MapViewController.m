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
#import "QuartzCore/CALayer.h"
#import "AddArtViewController.h"
#import "DetailTableControllerViewController.h"

static const int _kAnnotationLimit = 9999;

@interface MapViewController (private)
-(void)artUpdated;
-(void)filterButtonTapped;
-(void)addButtonTapped;
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
    
    //track map view
    [Utilities trackPageViewWithName:@"MapView"];
    
	//the map needs to be refreshed
	_mapNeedsRefresh = YES;
    
    //refresh button
    UIImage *mapButtonImage = [UIImage imageNamed:@"MapIcon.png"];
    UIImage *listButtonImage = [UIImage imageNamed:@"ListIcon.png"];
      UIImage  *keyButtonImage = [UIImage imageNamed:@"key.png"];
    _listButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, mapButtonImage.size.width, mapButtonImage.size.height)];
    [_listButton setImage:listButtonImage];
    _mapButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, listButtonImage.size.width, listButtonImage.size.height)];
    [_mapButton setImage:mapButtonImage];
    _listButton.backgroundColor = [UIColor clearColor];
    _mapButton.backgroundColor = [UIColor clearColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:self action:@selector(flipMap) forControlEvents:UIControlEventTouchUpInside];
    btn.frame = CGRectMake(0, 0, listButtonImage.size.width, listButtonImage.size.height + 10.0);
    
    UIView *buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mapButtonImage.size.width + 5.0f, mapButtonImage.size.height + 15.0f)];
    buttonView.backgroundColor = [UIColor clearColor];
    
    UILabel *btnLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, btn.frame.size.height - 5.0f, btn.frame.size.width, 10.0f)];
    [btnLabel setText:@"List"];
    [btnLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f]];
    [btnLabel setTextColor:[UIColor colorWithRed:(180.0f/255.0f) green:(174.0f/255.0f) blue:(174.0f/255.0f) alpha:1.0]];
    [btnLabel setBackgroundColor:[UIColor clearColor]];
    [btnLabel setTextAlignment:NSTextAlignmentCenter];
    [btnLabel setTag:10];
    
    [buttonView addSubview:_listButton];
    [buttonView addSubview:btn];
    [buttonView addSubview:btnLabel];
    
    //key Button
    keyButton = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, keyButtonImage.size.width+2, keyButtonImage.size.height+6)];
    [keyButton setImage:keyButtonImage];
    keyButton.backgroundColor=[UIColor clearColor];
    
    UIButton *btnKey = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    btnKey.frame = CGRectMake(0, 0, keyButtonImage.size.width, keyButtonImage.size.height + 10.0);
    
    buttonView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, mapButtonImage.size.width + 5.0f, mapButtonImage.size.height + 15.0f)];
    buttonView2.backgroundColor = [UIColor clearColor];
    
    UILabel *btnLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, btnKey.frame.size.height - 5.0f, btnKey.frame.size.width, 10.0f)];
    [btnLabel2 setText:@"Key"];
    [btnLabel2 setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0f]];
    [btnLabel2 setTextColor:[UIColor colorWithRed:(180.0f/255.0f) green:(174.0f/255.0f) blue:(174.0f/255.0f) alpha:1.0]];
    [btnLabel2 setBackgroundColor:[UIColor clearColor]];
    [btnLabel2 setTextAlignment:NSTextAlignmentCenter];
    [btnLabel2 setTag:10];
    
    [buttonView2 addSubview:keyButton];
    [buttonView2 addSubview:btnKey];
    [buttonView2 addSubview:btnLabel2];
    
    UIBarButtonItem *flipButton1 = [[UIBarButtonItem alloc] initWithCustomView:buttonView2];
    [flipButton1 setTarget:self];
    [flipButton1 setAction:@selector(openView)];
    
    [self.navigationItem setLeftBarButtonItem:flipButton1];
    
    UIBarButtonItem *flipButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    [flipButton setTarget:self];
    [flipButton setAction:@selector(flipMap)];
    
    [self.navigationItem setRightBarButtonItem:flipButton];

    
    //setup the list view
    [_listViewController.tableView setFrame:CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height)];
    _listViewController.delegate = self;
    [_listViewController.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
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
	[self.mapView.addArtButton addTarget:self action:@selector(addButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.filterButton addTarget:self action:@selector(filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.locateButton addTarget:self action:@selector(locateButtonTapped) forControlEvents:UIControlEventTouchUpInside];

    //bg color
    [self.view setBackgroundColor:[UIColor blackColor]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([Utilities is7OrHigher])
        [self setNeedsStatusBarAppearanceUpdate];
      viewhide=YES;
    [self loadNewView];

}
-(void)openView
{
    if (viewhide==YES) {
        keyView.hidden=NO;
        [self.view bringSubviewToFront:keyView];
        viewhide=NO;
    }
    else{
        viewhide=YES;
        keyView.hidden=YES;
    }
    
}
-(void)loadNewView
{
    keyView =[[UIView alloc]init];
    if([Utilities instance].selectedFilterType == FilterTypeNone && !_showFavorites)
    {
        keyView.frame=CGRectMake(0,0, self.view.frame.size.width-90, 250);
    }
    else{
        keyView.frame=CGRectMake(0,30, self.view.frame.size.width-90, 250);
        
    }
    keyView.backgroundColor=[UIColor whiteColor];
    [self.view bringSubviewToFront:keyView];
    [self.view addSubview:keyView];
    keyView.hidden=YES;
    
    //    rgb(230,77,70)
    
    UIButton *community = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    community.frame = CGRectMake(5, 5, keyView.frame.size.width, 20);
    [community setTitle:@"\t\tCommunity" forState:UIControlStateNormal];
    [community setTintColor:[UIColor colorWithRed:(230.0f/255.0f) green:(77.0f/255.0f) blue:(70.0f/255.0f) alpha:1.0]];
    [community setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    community.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //  [community setImage:[UIImage imageNamed:@"Pinred.png"] forState:UIControlStateNormal];
    // [community setImageEdgeInsets:UIEdgeInsetsMake(0, 0 , 0, 0)];
    [self.view bringSubviewToFront:community];
    [keyView addSubview:community];
    
    UIImage  *keyImage = [UIImage imageNamed:@"pin_red.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)];
    [imageView setImage:keyImage];
    [community addSubview:imageView];
    
    UILabel *lableforcomm=[[UILabel alloc]initWithFrame:CGRectMake(10, community.frame.size.height-3, community.frame.size.width, 10)];
    lableforcomm.text=@"\t      art uploaded by anyone, anywhere";
    lableforcomm.textColor=[UIColor blackColor];
    [lableforcomm setFont:[UIFont systemFontOfSize:10]];
    [lableforcomm sizeToFit];
    [community addSubview:lableforcomm];
    
    //rgb(95,190,195)
    UIButton *catalog = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    catalog.frame = CGRectMake(5, community.frame.size.height+30, keyView.frame.size.width, 20);
    [catalog setTitle:@"\t\tCatalog" forState:UIControlStateNormal];
    [catalog setTintColor:[UIColor colorWithRed:(95.0f/255.0f) green:(190.0f/255.0f) blue:(195.0f/255.0f) alpha:1.0]];
    [catalog setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    catalog.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // [catalog setImage:[UIImage imageNamed:@"Pinteal.png"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:catalog];
    [keyView addSubview:catalog];
    UIImage  *catalogImage = [UIImage imageNamed:@"pin_green.png"];
    UIImageView *catalogimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)];
    [catalogimageView setImage:catalogImage];
    [catalog addSubview:catalogimageView];
    UILabel *lableforcatalog=[[UILabel alloc]initWithFrame:CGRectMake(10, catalog.frame.size.height-3, catalog.frame.size.width, 10)];
    lableforcatalog.text=@"\t      researched art";
    lableforcatalog.textColor=[UIColor blackColor];
    [lableforcatalog setFont:[UIFont systemFontOfSize:10]];
    [lableforcatalog sizeToFit];
    [catalog addSubview:lableforcatalog];
    
    //rgb(231,181,0)
    UIButton *streetart = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    streetart.frame = CGRectMake(5, catalog.frame.size.height+80, keyView.frame.size.width, 20);
    [streetart setTitle:@"\t\tStreet art hot spots" forState:UIControlStateNormal];
    [streetart setTintColor:[UIColor colorWithRed:(231.0f/255.0f) green:(181.0f/255.0f) blue:(0.0f/255.0f) alpha:1.0]];
    [streetart setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    streetart.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //[streetart setImage:[UIImage imageNamed:@"Pinyellow.png"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:streetart];
    [keyView addSubview:streetart];
    
    UIImage  *streetartImage = [UIImage imageNamed:@"pin_yellow.png"];
    UIImageView *streetartimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)];
    [streetartimageView setImage:streetartImage];
    [streetart addSubview:streetartimageView];
    
    UILabel *lableforstreetart=[[UILabel alloc]initWithFrame:CGRectMake(10, streetart.frame.size.height-3, streetart.frame.size.width, 10)];
    lableforstreetart.text=@"\t      walls repainted frequently";
    lableforstreetart.textColor=[UIColor blackColor];
    [lableforstreetart setFont:[UIFont systemFontOfSize:10]];
    [lableforstreetart sizeToFit];
    [streetart addSubview:lableforstreetart];
    
    //rgb(68,92,170)
    UIButton *museums = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    museums.frame = CGRectMake(5, catalog.frame.size.height+130, keyView.frame.size.width, 20);
    [museums setTitle:@"\t\tMuseums + Galleries" forState:UIControlStateNormal];
    [museums setTintColor:[UIColor colorWithRed:(68.0f/255.0f) green:(92.0f/255.0f) blue:(170.0f/255.0f) alpha:1.0]];
    [museums setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    museums.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //   [museums setImage:[UIImage imageNamed:@"Pinblue.png"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:museums];
    [keyView addSubview:museums];
    
    UIImage  *museumsImage = [UIImage imageNamed:@"pin_blue.png"];
    UIImageView *museumsimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)];
    [museumsimageView setImage:museumsImage];
    [museums addSubview:museumsimageView];
    
    UILabel *lableformuseums=[[UILabel alloc]initWithFrame:CGRectMake(10, museums.frame.size.height-3, museums.frame.size.width, 10)];
    lableformuseums.text=@"\t      art inside";
    lableformuseums.textColor=[UIColor blackColor];
    [lableformuseums setFont:[UIFont systemFontOfSize:10]];
    [lableformuseums sizeToFit];
    [museums addSubview:lableformuseums];
    
    //rgb(136,136,136)
    UIButton *artchive = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    //[btnKey addTarget:self action:@selector(openView) forControlEvents:UIControlEventTouchUpInside];
    artchive.frame = CGRectMake(5, catalog.frame.size.height+180, keyView.frame.size.width, 20);
    [artchive setTitle:@"\t\tArtchive" forState:UIControlStateNormal];
    [artchive setTintColor:[UIColor colorWithRed:(136.0f/255.0f) green:(136.0f/255.0f) blue:(136.0f/255.0f) alpha:1.0]];
    [artchive setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    artchive.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    // [artchive setImage:[UIImage imageNamed:@"Pinblue.png"] forState:UIControlStateNormal];
    [self.view bringSubviewToFront:artchive];
    [keyView addSubview:artchive];
    
    UIImage  *artchiveImage = [UIImage imageNamed:@"pin_gray.png"];
    UIImageView *artchiveimageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35,35)];
    [artchiveimageView setImage:artchiveImage];
    [artchive addSubview:artchiveimageView];
    
    UILabel *lableforartchive=[[UILabel alloc]initWithFrame:CGRectMake(10, artchive.frame.size.height-3, artchive.frame.size.width, 10)];
    lableforartchive.text=@"\t      remove + repainted art";
    lableforartchive.textColor=[UIColor blackColor];
    [lableforartchive setFont:[UIFont systemFontOfSize:10]];
    [lableforartchive sizeToFit];
    [artchive addSubview:lableforartchive];
    
}



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
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

    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
}



- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//clear out the navigation controller possibly set by another view controller
	[self.navigationController setDelegate:nil];
    
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


-(void)filterButtonTapped
{
	//create a top level filter controller and push it to the nav controller
	FilterViewController *filterController = [[FilterViewController alloc] init];
    [filterController.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [filterController.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
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
	if ([_items count] > self.callout.tag && [self.navigationController.topViewController class] != [DetailTableControllerViewController class]) {
		
		//get the selected art piece
		Art *selectedArt = [_items objectAtIndex:self.callout.tag];
		
		//pass it along to a new detail controller and push it the navigation controller
        DetailTableControllerViewController *detailController = [[DetailTableControllerViewController alloc] initWithStyle:UITableViewStylePlain art:selectedArt];
        [self.navigationController pushViewController:detailController animated:YES];
        [detailController release];
        
        //track Detail view
        [Utilities trackPageViewWithHierarch:[NSArray arrayWithObjects:@"MapView", @"DetailView", selectedArt.title, nil]];
        
	}
}

#pragma mark - Update Art

- (void)flipMap 
{
    UILabel *flipButtonLabel = (UILabel*)[[(UIBarButtonItem*)[self.navigationItem rightBarButtonItem] customView] viewWithTag:10];
    
    if (_showingMap) {
        [UIView transitionFromView:self.mapView toView:_listViewController.tableView duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        [UIView transitionFromView:_listButton toView:_mapButton duration:1 options:UIViewAnimationOptionTransitionFlipFromRight completion:nil];
        
        //set the button text
        [flipButtonLabel setText:@"Map"];
        
        //track list view
        [Utilities trackPageViewWithName:@"ListView"];
    }
    else {
        [UIView transitionFromView:_listViewController.tableView toView:self.mapView duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        [UIView transitionFromView:_mapButton  toView:_listButton duration:1 options:UIViewAnimationOptionTransitionFlipFromLeft completion:nil];
        
        //set the button text
        [flipButtonLabel setText:@"List"];
        
        //track map view
        [Utilities trackPageViewWithName:@"MapView"];
    }
    
    _showingMap = !_showingMap;
    
    if (_items) {
        //reset the list view
        [_listViewController setItems:_items];
    }
    
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
    categoryArray=[[NSMutableArray alloc]init];
        tagArray=[[NSMutableArray alloc]init];
    x=0;
	//get art from core data
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Art" inManagedObjectContext:[AAAPIManager managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:_kAnnotationLimit];
	
    //turn the header on or off
    if ([Utilities instance].selectedFilterType == FilterTypeNone && !_showFavorites)
    {
        self.mapView.headerView.alpha = 0;
     keyView.frame=CGRectMake(0,0, self.view.frame.size.width-90, 250);
    }
    else {
        self.mapView.headerView.alpha = 1;
         keyView.frame=CGRectMake(0,30, self.view.frame.size.width-90, 250);
        if ([Utilities instance].selectedFilterType != FilterTypeNone && _showFavorites)
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Filtered & Favorites"];
        else if ([Utilities instance].selectedFilterType == FilterTypeNone && _showFavorites)
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Favorites"];
        else
            [(UILabel*)[self.mapView.headerView viewWithTag:1] setText:@"Filtered"];
    }
    
	//setup the proper delegate for the selected filter
	switch ([Utilities instance].selectedFilterType) {
			
        case FilterTypeFavorites: {
			[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"favorite == TRUE"]];
            
			break;
		}
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
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:(_showFavorites) ? @"favorite == TRUE AND ANY categories.title IN %@" : @"ANY categories.title IN %@", categoriesTitles]];
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
        NSNumber *thisDist = [NSNumber numberWithDouble:([thisLoc distanceFromLocation:currentLoc] / 1609.3)];
        [thisArt setDistance:[NSDecimalNumber decimalNumberWithDecimal:[thisDist decimalValue]]];
    
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
    
    //track minimum and and max lat and long to set the map bounds
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
	//add annotations
	for (int i = 0; i < [_items count]; i++) {
		
		//add the annotation for the art
		Art *art = [_items objectAtIndex:i];
        
      
        Category *c=[[[art valueForKey:@"categories"] allObjects] lastObject];
        NSString*strcat =[c valueForKey:@"title" ];
        
        if (strcat) {
            [categoryArray insertObject:strcat atIndex:i];
             x++;
            
        }
        else
        {
             [categoryArray insertObject:@"nil" atIndex:i];
        }
        NSString *tag =[art tagString];
        if (tag) {
            [tagArray insertObject:tag atIndex:i];
            x++;
            
        }
        else
        {
            [tagArray insertObject:@"nil" atIndex:i];
        }

       
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
            
            //check for min and max lat/lon
            if (i == 0) {
                topLeftCoord.longitude = artLocation.longitude;
                topLeftCoord.latitude = artLocation.latitude;
                bottomRightCoord.longitude = artLocation.longitude;
                bottomRightCoord.latitude = artLocation.latitude;
            }
            else {
                
                topLeftCoord.longitude = fmin(topLeftCoord.longitude, artLocation.longitude);
                topLeftCoord.latitude = fmax(topLeftCoord.latitude, artLocation.latitude);
                
                bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, artLocation.longitude);
                bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, artLocation.latitude);
                
            }
			
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
    
    //set map region
    [Utilities zoomToFitMapAnnotations:_mapView.map];
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
            NSString *string =[tagArray objectAtIndex:index ];
            NSMutableArray *arraySort = [[NSMutableArray alloc] init];
            NSMutableArray * array = [[NSMutableArray alloc] init];
            array = [string componentsSeparatedByString:@","];
            for (int i=0; i<array.count; i++) {
                NSString *str =[array objectAtIndex:i];
                if(str.length!=0)
                {
                    NSString *str2 = [[str stringByReplacingOccurrencesOfString:@" " withString:@""] capitalizedString];
                    [arraySort addObject:str2];
                }
            }
            array = [[NSMutableArray alloc] init];
            array = [arraySort mutableCopy];
            for (int i =0; i<array.count; i++) {
                
                if ([[array objectAtIndex:i ]isEqualToString:@"Community"]||[[array objectAtIndex:i ]isEqualToString:@"community"]) {
                    //setup the pin image and reuse identifier
                    NSString *reuseIdentifier = nil;
                    UIImage *pinImage = nil;
                    
                    //new single pinart
                    reuseIdentifier = @"art";
                    pinImage = [UIImage imageNamed:@"pin_red.png"];
                    
                    //setup the annotation view
                    ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
                    [pin setImage:pinImage];
                    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                    [pin setCanShowCallout:NO];
                    [pin setTag:index];
                    
                    //return the annotion view
                    return pin;
                }
                else if ([[array objectAtIndex:i ]isEqualToString:@"Catalog"]||[[array objectAtIndex:i ]isEqualToString:@"catalog"]) {
                    //setup the pin image and reuse identifier
                    NSString *reuseIdentifier = nil;
                    UIImage *pinImage = nil;
                    
                    //new single pinart
                    reuseIdentifier = @"art";
                    pinImage = [UIImage imageNamed:@"pin_green.png"];
                    
                    //setup the annotation view
                    ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
                    [pin setImage:pinImage];
                    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                    [pin setCanShowCallout:NO];
                    [pin setTag:index];
                    
                    //return the annotion view
                    return pin;
                }
                
                if ([[array objectAtIndex:i ]isEqualToString:@"Streetarthotspot"] || [[array objectAtIndex:i ]isEqualToString:@"street art hot spot"] ) {
                    //setup the pin image and reuse identifier
                    NSString *reuseIdentifier = nil;
                    UIImage *pinImage = nil;
                    
                    //new single pinart
                    reuseIdentifier = @"art";
                    pinImage = [UIImage imageNamed:@"pin_yellow.png"];
                    
                    //setup the annotation view
                    ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
                    [pin setImage:pinImage];
                    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                    [pin setCanShowCallout:NO];
                    [pin setTag:index];
                    
                    //return the annotion view
                    return pin;
                }
                
                
                
                
                if ([[array objectAtIndex:i ]isEqualToString:@"Artchive"]||[[array objectAtIndex:i ]isEqualToString:@"artchive"]) {
                    //setup the pin image and reuse identifier
                    NSString *reuseIdentifier = nil;
                    UIImage *pinImage = nil;
                    
                    //new single pinart
                    reuseIdentifier = @"art";
                    pinImage = [UIImage imageNamed:@"pin_gray.png"];
                    
                    //setup the annotation view
                    ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
                    [pin setImage:pinImage];
                    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                    [pin setCanShowCallout:NO];
                    [pin setTag:index];
                    
                    //return the annotion view
                    return pin;
                }
                
            }
            NSString *string2 =[categoryArray objectAtIndex:index ];
            
            NSArray * array2 = [string2 componentsSeparatedByString:@","];
            for (int i =0; i<array2.count; i++) {
                if ([[array2 objectAtIndex:i ]isEqualToString:@"Museum"] || [[array2 objectAtIndex:i ]isEqualToString:@"Gallery"] ) {
                    //setup the pin image and reuse identifier
                    NSString *reuseIdentifier = nil;
                    UIImage *pinImage = nil;
                    
                    //new single pinart
                    reuseIdentifier = @"art";
                    pinImage = [UIImage imageNamed:@"pin_blue.png"];
                    
                    //setup the annotation view
                    ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier] autorelease];
                    [pin setImage:pinImage];
                    [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
                    [pin setCanShowCallout:NO];
                    [pin setTag:index];
                    
                    //return the annotion view
                    return pin;
                }}
            
            
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
//        [self.mapView.map setRegion:[self.mapView.map regionThatFits:MKCoordinateRegionMake(userLocation.coordinate, MKCoordinateSpanMake(0.09, 0.09))] animated:YES];
        _foundUser = YES;
    }
    
}

#pragma mark - Listview delegate
- (void) selectedArt:(Art*)art
{
    DetailTableControllerViewController *detailController = [[DetailTableControllerViewController alloc] initWithStyle:UITableViewStylePlain art:art];
    [self.navigationController pushViewController:detailController animated:YES];
    [detailController release];
    
    //track Detail view
    [Utilities trackPageViewWithHierarch:[NSArray arrayWithObjects:@"ListView", @"DetailView", art.title, nil]];
}
- (void)selectedArtAtIndex:(int)index
{

    //get the selected art piece
    Art *selectedArt = [_items objectAtIndex:index];
    
//    //pass it along to a new detail controller and push it the navigation controller
//    DetailViewController *detailController = [[DetailViewController alloc] init];
//    [self.navigationController pushViewController:detailController animated:YES];
//    
//    //set the location coord to the user's location and the art selected
//    detailController.currentLocation = self.mapView.map.userLocation.location;
//    [detailController setArt:selectedArt withTemplate:nil];
//    
//    [detailController release];
    
    //pass it along to a new detail controller and push it the navigation controller
    DetailTableControllerViewController *detailController = [[DetailTableControllerViewController alloc] initWithStyle:UITableViewStylePlain art:selectedArt];
    [self.navigationController pushViewController:detailController animated:YES];    
    [detailController release];
    
    //track Detail view
    [Utilities trackPageViewWithHierarch:[NSArray arrayWithObjects:@"ListView", @"DetailView", selectedArt.title, nil]];
    
}

- (NSDictionary*) currentLocation
{

    NSDictionary *locDict = [[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithDouble:self.mapView.map.userLocation.coordinate.latitude], @"lat", [NSNumber numberWithDouble:self.mapView.map.userLocation.coordinate.longitude], @"long", nil];
    return locDict;
    
}

- (void) listViewFilterButtonPressed {
    [self filterButtonTapped];
}

- (void) listViewAddArtButtonPressed {
    [self addButtonTapped];
    
}


@end
