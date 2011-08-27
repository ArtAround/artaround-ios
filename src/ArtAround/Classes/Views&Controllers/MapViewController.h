//
//  MapViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class MapView;

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
	NSMutableArray *_items;
	NSMutableArray *_annotations;
	BOOL _mapNeedsRefresh;
}

@property (nonatomic, retain) MapView *mapView;

@end
