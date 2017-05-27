//
//  ArtLocationSelectionViewViewController.m
//  ArtAround
//
//  Created by Brian Singer on 6/8/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "ArtLocationSelectionViewViewController.h"
#import "ArtAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

#define CLCOORDINATES_EQUAL( coord1, coord2 ) (coord1.latitude == coord2.latitude && coord1.longitude == coord2.longitude)

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
@synthesize locationLabel;
@synthesize delegate;
@synthesize location = _location, geotagLocation;
@synthesize selection = _selection;
@synthesize selectedLocation = _selectedLocation;

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
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
        self.location = loc;
        
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
    
    [self.locationLabel.layer setShadowColor:[UIColor blackColor].CGColor];
    
    if (self.geotagLocation) {
        CLLocation *geoLoc  = [[CLLocation alloc] initWithLatitude:geotagLocation.coordinate.latitude longitude:geotagLocation.coordinate.longitude];
        self.geotagLocation = geoLoc;
        
        //enable/disable geotag button
        [self.geotagButton setEnabled:YES];
        
    }
    else {
        self.geotagLocation = nil;
        //enable/disable geotag button
        [self.geotagButton setEnabled:NO];
        [self.geotagButton setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:0.7f]];
    }
    
    //setup save button
    UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55.0f, 30.0f)];
    [saveButton addTarget:self action:@selector(doneButonPressed) forControlEvents:UIControlEventTouchUpInside];
    [saveButton setBackgroundColor:[UIColor colorWithRed:(241.0f/255.0f) green:(164.0f/255.0f) blue:(162.0f/255.0f) alpha:1.0f]];
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f]];
    UIBarButtonItem *saveButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveButton];
    [self.navigationItem setRightBarButtonItem:saveButtonItem];
    
    //setup back button
    UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png"];
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, backButtonImage.size.width + 10.0f, backButtonImage.size.height)];
    [backButton addTarget:self.navigationController action:@selector(popViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:backButtonImage forState:UIControlStateNormal];
    [backButton setContentMode:UIViewContentModeCenter];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    [self.navigationItem setLeftBarButtonItem:backButtonItem];
    
    //map delegate
    [self.mapView setDelegate:self];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setCurrentLocationButton:nil];
    [self setGeotagButton:nil];
    [self setDoneButton:nil];
    [self setMapView:nil];
    [self setLocationLabel:nil];
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
                [self.mapView setRegion:region animated:YES];
                [self.mapView regionThatFits:region];
                
            }
            break;
        }
        case LocationSelectionPhotoLocation:
        {
            self.geotagButton.selected = YES;
            
            if (self.geotagLocation) {
                
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
                [self.mapView setRegion:region animated:YES];
                [self.mapView regionThatFits:region];
                
            }
            
            break;
        }
        case LocationSelectionManualLocation:
        {
            //get the selected location
            CLLocationCoordinate2D theLocation = self.selectedLocation.coordinate;
            
            //set the span
            MKCoordinateSpan span;
            span.latitudeDelta = 0.003f;
            span.longitudeDelta = 0.003f;
            
            //set the region
            MKCoordinateRegion region;
            region.span=span;
            region.center=theLocation;
            
            //zoom/pan the map on the user location
            [self.mapView setRegion:region animated:NO];
            [self.mapView regionThatFits:region];
            
            self.currentLocationButton.selected = NO;
            self.currentLocationButton.selected = NO;
            break;
        }
        default:
            break;
    }
    
    if (CLLocationCoordinate2DIsValid(self.mapView.region.center) && !CLCOORDINATES_EQUAL(CLLocationCoordinate2DMake(0, 0), self.mapView.region.center)) {
        CLLocation *selectedLoc = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
        _selectedLocation = selectedLoc;
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:_selectedLocation.coordinate.latitude longitude:_selectedLocation.coordinate.longitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            DebugLog(@"Error durring reverse geocode");
        }
        
        if (placemarks.count > 0) {
            [self.locationLabel setText:[[placemarks objectAtIndex:0] name]];
            [self.locationLabel setAlpha:1.0f];
        }
        else {
            [self.locationLabel setAlpha:0.0f];
        }
        
    }];
    
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
        
        ArtAnnotationView *pin = [[ArtAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
        [pin setImage:[UIImage imageNamed:@"PinArt.png"]];
        [pin setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeDetailDisclosure]];
        [pin setCanShowCallout:NO];
        
        //return the annotion view
        return pin;
        
    }
    
	//something must have gone wrong
	return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    CLLocation *selLoc = [[CLLocation alloc] initWithLatitude:self.mapView.region.center.latitude longitude:self.mapView.region.center.longitude];
    _selectedLocation = selLoc;
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocation *newLocation = [[CLLocation alloc] initWithLatitude:_selectedLocation.coordinate.latitude longitude:_selectedLocation.coordinate.longitude];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            DebugLog(@"Error durring reverse geocode");
        }
        
        if (placemarks.count > 0) {
            [self.locationLabel setText:[[placemarks objectAtIndex:0] name]];
            [self.locationLabel setAlpha:1.0f];
        }
        else {
            [self.locationLabel setAlpha:0.0f];
        }
        
    }];
    
}

@end
