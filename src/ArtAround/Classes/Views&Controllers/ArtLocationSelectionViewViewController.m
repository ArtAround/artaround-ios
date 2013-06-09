//
//  ArtLocationSelectionViewViewController.m
//  ArtAround
//
//  Created by Brian Singer on 6/8/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "ArtLocationSelectionViewViewController.h"
#import "ArtAnnotationView.h"

@interface ArtLocationSelectionViewViewController ()
- (void) doneButonPressed;
- (void) currentLocationButonPressed;
- (void) geotagButonPressed;
@end

@implementation ArtLocationSelectionViewViewController
@synthesize currentLocationButton;
@synthesize geotagButton;
@synthesize doneButton;
@synthesize mapView;
@synthesize delegate;
@synthesize location, geotagLocation;
@synthesize selection = _selection;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil geotagLocation:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil geotagLocation:newGeotagLocation delegate:nil currentLocationSelection:LocationSelectionUserLocation];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation
{
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil geotagLocation:newGeotagLocation delegate:myDelegate currentLocationSelection:selectedLocation currentLocation:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation currentLocation:(CLLocation*)newLocation
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.selection = selectedLocation;
        self.geotagLocation = newGeotagLocation;
        [self.currentLocationButton setSelected:YES];
        self.location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        
        //set delegate
        self.delegate = myDelegate;
        
        
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self setSelection:_selection];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.geotagLocation) {
        self.geotagLocation = [[CLLocation alloc] initWithLatitude:geotagLocation.coordinate.latitude longitude:geotagLocation.coordinate.longitude];
        
        //enable/disable geotag button
        [self.geotagButton setEnabled:YES];
    }
    else {
        self.geotagLocation = nil;
        //enable/disable geotag button
        [self.geotagButton setEnabled:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [currentLocationButton release];
    [geotagButton release];
    [doneButton release];
    [mapView release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setCurrentLocationButton:nil];
    [self setGeotagButton:nil];
    [self setDoneButton:nil];
    [self setMapView:nil];
    [super viewDidUnload];
}
- (IBAction)buttonPressed:(id)sender {
    
    switch ([(UIButton*)sender tag]) {
        case 1:
            [self currentLocationButonPressed];
            break;
        case 2:
            [self geotagButonPressed];
            break;
        case 3:
            [self doneButonPressed];
            break;
        default:
            break;
    }
}

- (LocationSelection) selection
{
    return _selection;
}

- (void) setSelection:(LocationSelection)newSelection
{
    //set selection
    _selection = newSelection;
    
    //remove existing annotations
    [self.mapView removeAnnotation:_annotation];
    
    switch (newSelection) {
        case LocationSelectionUserLocation:
        {
            self.currentLocationButton.selected = YES;
            
            if (self.location) {
                _annotation = [[ArtAnnotation alloc] initWithCoordinate:self.location.coordinate title:@"" subtitle:@""];
                [self.mapView addAnnotation:_annotation];
                
                //get the user location
                CLLocationCoordinate2D theLocation = self.location.coordinate;
                
                //set the span
                MKCoordinateSpan span;
                span.latitudeDelta = 0.003f;
                span.longitudeDelta = 0.003f;
                
                //set the region
                MKCoordinateRegion region;
                region.span=span;
                region.center=theLocation;
                
                //zoom/pan the map on the user location
                [self.mapView setRegion:region animated:TRUE];
                [self.mapView regionThatFits:region];
                
                break;
            }
        }
        case LocationSelectionPhotoLocation:
        {
            self.geotagButton.selected = YES;
            
            if (self.geotagLocation) {
                _annotation = [[ArtAnnotation alloc] initWithCoordinate:self.geotagLocation.coordinate title:@"" subtitle:@""];
                [self.mapView addAnnotation:_annotation];
                
                //get the user location
                CLLocationCoordinate2D theLocation = self.geotagLocation.coordinate;
                
                //set the span
                MKCoordinateSpan span;
                span.latitudeDelta = 0.003f;
                span.longitudeDelta = 0.003f;
                
                //set the region
                MKCoordinateRegion region;
                region.span=span;
                region.center=theLocation;
                
                //zoom/pan the map on the user location
                [self.mapView setRegion:region animated:TRUE];
                [self.mapView regionThatFits:region];
            }
            
            break;
        }
        default:
            break;
    }
    
}

- (void) doneButonPressed
{
    if (self.delegate && [(id)self.delegate canPerformAction:@selector(locationSelectionViewController:selected:) withSender:self]) {
        
        [self.delegate locationSelectionViewController:self selected:self.selection];
        
    }
}

- (void) currentLocationButonPressed
{
    self.selection = LocationSelectionUserLocation;
    self.geotagButton.selected = NO;
    self.currentLocationButton.selected = YES;
}

- (void) geotagButonPressed
{
    self.selection = LocationSelectionPhotoLocation;
    self.geotagButton.selected = YES;
    self.currentLocationButton.selected = NO;
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
	//if it's the user location, just return nil.
	if ([annotation isKindOfClass:[MKUserLocation class]]) {
		return nil;
	}
	
	if ([annotation isKindOfClass:[ArtAnnotation class]]) {
        
        ArtAnnotationView *pin = [[[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil] autorelease];
        [pin setImage:[UIImage imageNamed:@"PinArt.png"]];
        [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        [pin setCanShowCallout:NO];
        
        //return the annotion view
        return pin;
        
    }
    
	//something must have gone wrong
	return nil;
}

@end
