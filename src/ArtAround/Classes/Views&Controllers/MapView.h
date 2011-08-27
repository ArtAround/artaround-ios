//
//  MapView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapView : UIView

@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) UIButton *filterButton;

@end
