//
//  CalloutAnnotationView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/30/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class Art;
@class ArtAnnotationView;

@interface CalloutAnnotationView : MKAnnotationView <MKAnnotation> 

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, assign) Art *art;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, assign) ArtAnnotationView *parentAnnotationView;
@property (nonatomic, retain) MKMapView *mapView;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate frame:(CGRect)frame;

@end
