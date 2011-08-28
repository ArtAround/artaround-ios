//
//  DetailView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface DetailView : UIView

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) MKMapView *mapView;

@end
