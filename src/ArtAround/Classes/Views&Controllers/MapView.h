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

@property (nonatomic, strong) MKMapView *map;
@property (nonatomic, strong) UIButton *addArtButton;
@property (nonatomic, strong) UIButton *filterButton;
@property (nonatomic, strong) UIButton *locateButton;
@property (nonatomic, strong) UIView *headerView;

@end
