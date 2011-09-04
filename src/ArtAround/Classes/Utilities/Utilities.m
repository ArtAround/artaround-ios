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
#import "ASIHTTPRequest.h"

static Utilities *_kSharedInstance = nil;

@interface Utilities (private)
- (NSString *)keyForFilterType:(FilterType)filterType;
@end

@implementation Utilities
@synthesize selectedFilterType = _selectedFilterType, keysDict = _keysDict;

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
		
		//setup the keys dictionary
		NSString *settingsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ArtAround-Keys.plist"];
		NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsLocation];
		[self setKeysDict:settingsDict];
		[settingsDict release];

	}
	return self;
}

- (void)dealloc
{
	[self setKeysDict:nil];
	[super dealloc];
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

#pragma mark - activity indicator methods

//adds to the activity count which spins the network activity indicator
- (void)startActivity
{	
	//we are manually updating the activity indicator
	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	
	//increment the activity count
	//show start the activity indicator
	_activityCount++;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

//subtract from the activity count
//if the count reaches zero, stop the network activity indicator
- (void)stopActivity {
	
	if (--_activityCount <= 0) {
		_activityCount = 0;
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
		//we are no longer updating the activity indicator
		[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	}		
}

#pragma mark - device methods

//determines if this is a newer device based on the screen scale and if this is an ipad or not
//UIScreen scale is only available in ios 4+ and will be larger than 1.0 for retina devices
+ (BOOL)isNewHardware {
	
	//is this an ipad
	//not using UI_USER_INTERFACE_IDIOM because that returns NO when running an iPhone interface on an iPad
	if (NSClassFromString(@"UIPopoverController")) {
		return YES;
	}
	
	//is this a retina display device
	UIScreen *screen = [UIScreen mainScreen];
	if ([screen respondsToSelector:@selector(scale)]) {
		if (screen.scale > 1.0f) {
			return YES;
		}
	}
	
	//default to no
	return NO;
}

@end
