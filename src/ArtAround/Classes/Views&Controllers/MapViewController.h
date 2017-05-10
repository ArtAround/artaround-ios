//
//  MapViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "ListViewController.h"

@class MapView;
@class CalloutAnnotationView;

@interface MapViewController : UIViewController <MKMapViewDelegate, UIActionSheetDelegate, ListViewControllerDelegate>
{
	NSMutableArray *_items;
	NSMutableArray *_annotations;
	BOOL _mapNeedsRefresh, _showingMap, _foundUser, _firstLoad;
    UIImageView *_listButton, *_mapButton;
    UIView *_initialLoadView;
}

@property BOOL showFavorites;
@property (nonatomic, strong) MapView *mapView;
@property (nonatomic, strong) ListViewController *listViewController;
@property (nonatomic, strong) CalloutAnnotationView *callout;
@property (nonatomic, strong) CLLocationManager *locationManager;

-(void)updateAndShowArt:(Art*)showArt;
-(void)updateArt;
-(void)refreshArt;

@end
