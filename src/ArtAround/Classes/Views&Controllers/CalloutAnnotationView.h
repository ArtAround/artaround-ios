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

@property (nonatomic, weak) Art *art;
@property (nonatomic, weak) ArtAnnotationView *parentAnnotationView;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) EGOImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *artistLabel;
@property (nonatomic, strong) UILabel *summaryLabel;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate frame:(CGRect)frame;

@end
