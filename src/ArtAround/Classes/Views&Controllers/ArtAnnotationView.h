//
//  ArtAnnotationView.h
//  ArtAround
//
//  Created by Brandon Jones on 8/31/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface ArtAnnotationView : MKAnnotationView

@property (nonatomic) BOOL preventSelectionChange;

@end
