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
	self.mapView = aMapView;
	self.mapView.map.delegate = self;
	[self.view addSubview:self.mapView];
	[aMapView release];
	
	//default to dc map
	MKCoordinateSpan spanDC = MKCoordinateSpanMake(0.09, 0.09);
	CLLocationCoordinate2D centerDC;
	centerDC.latitude = 38.895;
	centerDC.longitude = -77.022;
	[self.mapView.map setRegion:[self.mapView.map regionThatFits:MKCoordinateRegionMake(centerDC, spanDC)]];
	
	//setup button actions
	[self.mapView.filterButton addTarget:self action:@selector(filterButtonTapped) forControlEvents:UIControlEventTouchUpInside];
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
	
	//update the map if needed
	if (_mapNeedsRefresh) {
		[[AAAPIManager instance] downloadAllArtWithTarget:self callback:@selector(artUpdated)];
		[self updateArt];
	}
}

- (void)dealloc
{
	[super dealloc];
	[self setMapView:nil];
}

#pragma mark - Button Actions

-(void)filterButtonTapped
{
	//create a top level filter controller and push it to the nav controller
	FilterViewController *filterController = [[FilterViewController alloc] init];
	[self.navigationController pushViewController:filterController animated:YES];
	[filterController release];
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

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
}

@end
