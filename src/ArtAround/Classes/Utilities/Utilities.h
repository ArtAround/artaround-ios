//
//  Utilities.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKMapView;

typedef enum {
	FilterTypeNone = 0,
    FilterTypeFavorites = 1,
	FilterTypeCategory = 2,
	FilterTypeNeighborhood = 3,
	FilterTypeTitle = 4,
	FilterTypeArtist = 5,
} FilterType;

@interface Utilities : NSObject
{
	NSUserDefaults *_defaults;
	int _activityCount;
}

@property (nonatomic, assign) FilterType selectedFilterType;
@property (nonatomic, retain) NSDictionary *keysDict;

+ (Utilities *)instance;
+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView;
- (NSArray *)getFiltersForFilterType:(FilterType)filterType;
- (void)setFilters:(NSArray *)filters forFilterType:(FilterType)filterType;
- (void)startActivity;
- (void)stopActivity;
+ (BOOL)isNewHardware;
+ (void)showLogoView:(BOOL)show inNavigationBar:(UINavigationBar *)navBar;

@end
