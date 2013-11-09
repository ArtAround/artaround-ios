//
//  ArtAnnotation.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface ArtAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) NSInteger index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate title:(NSString *)theTitle subtitle:(NSString *)theSubTitle;

@end
