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
	BOOL _mapNeedsRefresh, _showingMap, _foundUser;
    UIImageView *_listButton, *_mapButton;
    UIView *_initialLoadView;
}

@property BOOL showFavorites;
@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) ListViewController *listViewController;
@property (nonatomic, retain) CalloutAnnotationView *callout;

-(void)updateAndShowArt:(Art*)showArt;
-(void)updateArt;
-(void)refreshArt;

@end
