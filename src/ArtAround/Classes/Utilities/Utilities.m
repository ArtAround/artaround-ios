//
//  Utilities.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "Utilities.h"
#import <MapKit/MapKit.h>
#import "ArtAnnotation.h"

static Utilities *_kSharedInstance = nil;

@interface Utilities (private)
- (NSString *)keyForFilterType:(FilterType)filterType;
@end

@implementation Utilities
@synthesize selectedFilterType = _selectedFilterType;

//singleton
+ (Utilities *)instance
{	
	@synchronized(self)	{
		if (_kSharedInstance == nil)
			_kSharedInstance = [[Utilities alloc] init];
	}
	return _kSharedInstance;
}

- (id)init
{
	self = [super init];
	if (self) {

		//used to get settings from nsuserdefaults in various properties below
		_defaults = [NSUserDefaults standardUserDefaults];
		
		//set an invalid filter type so it is forced to pull from NSUserDefaults on first load
		_selectedFilterType = -1;

	}
	return self;
}

#pragma mark - Map Methods

+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView {
    if([mapView.annotations count] == 0) {
        return;
	}
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(ArtAnnotation *annotation in mapView.annotations) {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
	
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
	
	//adjust the annotation padding depending on the zoom level
	int offset = bottomRightCoord.longitude - topLeftCoord.longitude;
	float multiplier = (offset > 30) ? 1.1 : 1.4;
	
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * multiplier; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * multiplier; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}

#pragma mark - Filter Methods

- (void)setSelectedFilterType:(FilterType)aFilterType
{
	_selectedFilterType = aFilterType;
	[_defaults setInteger:aFilterType forKey:@"AAFilterType"];
}

- (FilterType)selectedFilterType
{
	if (_selectedFilterType == -1) {
		_selectedFilterType = [_defaults integerForKey:@"AAFilterType"];
	}
	return _selectedFilterType;
}

- (NSArray *)getFiltersForFilterType:(FilterType)filterType
{
	return [_defaults objectForKey:[self keyForFilterType:filterType]];
}

- (void)setFilters:(NSArray *)filters forFilterType:(FilterType)filterType
{
	//if no filters, remove all other filters
	//else set the filters
	if (filterType == FilterTypeNone) {
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeCategory]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeNeighborhood]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeArtist]];
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeTitle]];
	} else {
		[_defaults setObject:filters forKey:[self keyForFilterType:filterType]];
	}
}

- (NSString *)keyForFilterType:(FilterType)filterType
{
	return [NSString stringWithFormat:@"AAFilters_%i", filterType];
}

@end
