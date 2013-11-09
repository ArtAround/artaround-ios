//
//  ArtLocationSelectionViewViewController.h
//  ArtAround
//
//  Created by Brian Singer on 6/8/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ArtAnnotation.h"

typedef enum _LocationSelection {
    LocationSelectionUserLocation = 0,
    LocationSelectionPhotoLocation = 1,
    LocationSelectionManualLocation = 2
} LocationSelection;

@protocol ArtLocationSelectionViewViewControllerDelegate;

@interface ArtLocationSelectionViewViewController : UIViewController <MKMapViewDelegate>
{
    ArtAnnotation *_annotation;
}
@property LocationSelection selection;
@property (weak, nonatomic) CLLocation *location, *geotagLocation, *selectedLocation;
@property (weak, nonatomic) id <ArtLocationSelectionViewViewControllerDelegate> delegate;
@property (strong, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (strong, nonatomic) IBOutlet UIButton *geotagButton;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation currentLocation:(CLLocation*)newLocation;

- (IBAction)buttonPressed:(id)sender;

@end

@protocol ArtLocationSelectionViewViewControllerDelegate

- (void) locationSelectionViewController:(ArtLocationSelectionViewViewController*)controller selected:(LocationSelection)selection;

@end
