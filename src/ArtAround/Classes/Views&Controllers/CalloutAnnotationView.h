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
@class EGOImageView;

@interface CalloutAnnotationView : MKAnnotationView <MKAnnotation> 

@property (nonatomic, assign) Art *art;
@property (nonatomic, assign) ArtAnnotationView *parentAnnotationView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UIButton *button;
@property (nonatomic, retain) EGOImageView *imageView;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *artistLabel;
@property (nonatomic, retain) UILabel *summaryLabel;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate frame:(CGRect)frame;

@end
