//
//  MapViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class MapView;
@class CalloutAnnotationView;

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
	NSMutableArray *_items;
	NSMutableArray *_annotations;
	BOOL _mapNeedsRefresh;
}

@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) CalloutAnnotationView *callout;

- (void)updateArt;

@end
