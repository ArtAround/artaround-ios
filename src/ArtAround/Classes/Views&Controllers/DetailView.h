//
//  DetailView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

static const float _kMapHeight = 175.0f;
static const float _kMapPadding = 11.0f;
static const float _kPhotoScrollerHeight = 150.0f;
static const float _kSubmitButtonBarHeight = 45.0f;

@interface DetailView : UIView

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIScrollView *photosScrollView;
@property (nonatomic, retain) UIToolbar *bottomToolbar;
@property (nonatomic, retain) UIButton *submitButton, *favoriteButton;

@end
