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
    LocationSelectionPhotoLocation = 1
} LocationSelection;

@protocol ArtLocationSelectionViewViewControllerDelegate;

@interface ArtLocationSelectionViewViewController : UIViewController
{
    ArtAnnotation *_annotation;
}
@property LocationSelection selection;
@property (assign, nonatomic) CLLocation *location, *geotagLocation;
@property (assign, nonatomic) id <ArtLocationSelectionViewViewControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *currentLocationButton;
@property (retain, nonatomic) IBOutlet UIButton *geotagButton;
@property (retain, nonatomic) IBOutlet UIButton *doneButton;
@property (retain, nonatomic) IBOutlet MKMapView *mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil geotagLocation:(CLLocation*)newGeotagLocation delegate:(id <ArtLocationSelectionViewViewControllerDelegate>)myDelegate currentLocationSelection:(LocationSelection)selectedLocation currentLocation:(CLLocation*)newLocation;

- (IBAction)buttonPressed:(id)sender;

@end

@protocol ArtLocationSelectionViewViewControllerDelegate

- (void) locationSelectionViewController:(ArtLocationSelectionViewViewController*)controller selected:(LocationSelection)selection;

@end
