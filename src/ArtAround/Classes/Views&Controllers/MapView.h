//
//  MapView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapView : UIView

@property (nonatomic, retain) MKMapView *map;
@property (nonatomic, retain) UIButton *addArtButton;
@property (nonatomic, retain) UIButton *filterButton;
@property (nonatomic, retain) UIButton *locateButton;
@property (nonatomic, retain) UIView *headerView;

@end
