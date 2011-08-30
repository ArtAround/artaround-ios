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
#import "DetailViewController.h"

static const int _kAnnotationLimit = 9999;

@interface MapViewController (private)
- (void)artUpdated;
-(void)filterButtonTapped;
@end

@implementation MapViewController
@synthesize mapView = _mapView;

#pragma mark - View lifecycle

- (id)init
{
    self = [super init];
    if (self) {
		
		//initialize controller
		self.title = @"ArtAround";
		
		//initialize arrays
		_items = [[NSMutableArray alloc] init];
		_annotations = [[NSMutableArray alloc] init];
		
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)loadView
{
	[super loadView];
	
	//the map needs to be refreshed
	_mapNeedsRefresh = YES;
	
	//setup the map view
	MapView *aMapView = [[MapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, [[self view] frame].size.width, [[self view] frame].size.height)];
	[self setMapView:aMapView];
	[self.mapView.map setDelegate:self];
	[self.view addSubview:self.mapView];
	[aMapView release];
	
	//default to dc map
	MKCoordinateSpan spanDC = MKCoordinateSpanMake(0.09, 0.09);
	CLLocationCoordinate2D centerDC;
	centerDC.latitude = 38.895;
	centerDC.longitude = -77.022;
	[self.mapView.map setRegion:[self.mapView.map regionThatFits:MKCoordinateRegionMake(centerDC, spanDC)]];
	
	//setup button actions
	[self.mapView.shareButton addTarget:self action:@selector(shareButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.filterButton addTarget:self action:@selector(filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.mapView.locateButton addTarget:self action:@selector(locateButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	//add the logo to the navigation bar
	UIImage *logo = [UIImage imageNamed:@"ArtAroundLogo.png"];
	UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
	[logoView setFrame:CGRectMake(0.0f, 0.0f, logo.size.width, logo.size.height)];
	[logoView setContentMode:UIViewContentModeScaleAspectFit];
	[logoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[self.navigationItem setTitleView:logoView];
	[logoView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
	[self setMapView:nil];
	[self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	//clear out the navigation controller possibly set by another view controller
	[self.navigationController setDelegate:nil];
	
	//update the map if needed
	if (_mapNeedsRefresh) {
		[[AAAPIManager instance] downloadAllArtWithTarget:self callback:@selector(artUpdated)];
		[self updateArt];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)dealloc
{
	[_items release];
	[_annotations release];
	[self.mapView.map setDelegate:nil];
	[self setMapView:nil];
	[super dealloc];
}

#pragma mark - Button Actions

- (void)shareButtonTapped
{
	//todo: share
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

#pragma mark - Update Art

//called by AAAPIManager when new art is downloaded
- (void)artUpdated
{
	_mapNeedsRefresh = YES;
	[self updateArt];
}

//queries core data for art and adds them to the map
- (void)updateArt
{	
	//get art from core data
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"Art" inManagedObjectContext:[AAAPIManager managedObjectContext]];
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:_kAnnotationLimit];
	
	//setup the proper delegate for the selected filter
	switch ([Utilities instance].selectedFilterType) {
			
		case FilterTypeArtist: {
			NSArray *artists = [[Utilities instance] getFiltersForFilterType:FilterTypeArtist];
			if (artists) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"artist IN %@", artists]];
			}
			break;
		}
		case FilterTypeTitle: {
			NSArray *titles = [[Utilities instance] getFiltersForFilterType:FilterTypeTitle];
			if (titles) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title IN %@", titles]];
			}
		}
		case FilterTypeCategory: {
			NSArray *categoriesTitles = [[Utilities instance] getFiltersForFilterType:FilterTypeCategory];
			if (categoriesTitles) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"category.title IN %@", categoriesTitles]];
			}
		}
		case FilterTypeNeighborhood: {
			NSArray *neighborhoodTitles = [[Utilities instance] getFiltersForFilterType:FilterTypeNeighborhood];
			if (neighborhoodTitles) {
				[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"neighborhood.title IN %@", neighborhoodTitles]];
			}
		}
		default:
			break;
			
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
	
	//release fetch request
	[fetchRequest release];
	
	//check for errors
	if (!_items || error) {
		return;
	}
	
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
		
	}
	
	//add annotations
	[_mapView.map performSelectorOnMainThread:@selector(addAnnotations:) withObject:_annotations waitUntilDone:YES];
	_mapNeedsRefresh = NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	//if the annotation is not an ArtAnnotation, it's probably a system annotation like the user location
	if (![annotation isKindOfClass:[ArtAnnotation class]]) {
		return nil;
	}
	
	//setup the annotation view
    MKPinAnnotationView *pin = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
	pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    pin.canShowCallout = YES;
	pin.animatesDrop = NO;
	pin.tag = [(ArtAnnotation *)annotation index];
    
    return pin;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	if ([_items count] > view.tag) {
		
		//get the selected art piece
		Art *selectedArt = [_items objectAtIndex:view.tag];
		
		//pass it along to a new detail controller and push it the navigation controller
		DetailViewController *detailController = [[DetailViewController alloc] init];
		[self.navigationController pushViewController:detailController animated:YES];
		[detailController setArt:selectedArt];
		[detailController release];
		
	}
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
}

@end
