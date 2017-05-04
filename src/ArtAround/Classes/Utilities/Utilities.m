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
#import <Google/Analytics.h>

static Utilities *_kSharedInstance = nil;

@interface Utilities (private)
- (NSString *)keyForFilterType:(FilterType)filterType;
@end

@implementation Utilities
@synthesize selectedFilterType = _selectedFilterType, keysDict = _keysDict, lastFlickrUpdate = _lastFlickrUpdate, photoAttributionText = _photoAttributionText, photoAttributionURL = _photoAttributionURL, commentName = _commentName, commentEmail = _commentEmail, commentUrl = _commentUrl, flashMode = _flashMode;

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
		_selectedFilterType = FilterTypeUnchosen;
		
		//setup the keys dictionary
		NSString *settingsLocation = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"ArtAround-Keys.plist"];
		NSDictionary *settingsDict = [[NSDictionary alloc] initWithContentsOfFile:settingsLocation];
		[self setKeysDict:settingsDict];

	}
	return self;
}


- (BOOL) hasLoadedBefore
{
    NSNumber *firstLoad = [_defaults objectForKey:@"aa_newfirstLoad"];
    return [firstLoad boolValue];
}

- (void) setHasLoadedBefore:(BOOL)hasLoadedBefore
{
    NSNumber *firstLoad = [[NSNumber alloc] initWithBool:hasLoadedBefore];
    [_defaults setObject:firstLoad forKey:@"aa_newfirstLoad"];
    [_defaults synchronize];
}

#pragma mark - Helper Methods
+ (NSString *)urlEncode:(NSString *)string {
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)string, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), kCFStringEncodingUTF8));
}

+ (NSString *)urlDecode:(NSString *)string {
    NSStringEncoding encoding = string.fastestEncoding;
    if (encoding == NSUTF8StringEncoding) {
        return [string stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
	return [string stringByReplacingPercentEscapesUsingEncoding:encoding];
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

    region.span = MKCoordinateSpanMake(fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * multiplier, fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * multiplier);
    
    //male sure lat and long delta aren't 0
    if (region.span.longitudeDelta == 0) {
        region.span.longitudeDelta = 0.001;
    }
    if (region.span.latitudeDelta == 0) {
        region.span.latitudeDelta = 0.001;
    }
    
    if (region.span.longitudeDelta < 60)
        region = [mapView regionThatFits:region];
    else {
        region.center.latitude = 40;
        region.center.longitude = -99;
        region.span.longitudeDelta = 30.0f;
        region.span.latitudeDelta = 30.0f;
    }
    
    [mapView setRegion:region animated:YES];
}

- (void)setLastFlickrUpdate:(NSDate *)lastFlickrUpdate
{
    _lastFlickrUpdate = lastFlickrUpdate;
	[_defaults setObject:lastFlickrUpdate forKey:@"AAFlickrDate"];    
}

- (NSDate*)lastFlickrUpdate
{
    return _lastFlickrUpdate;
}

- (void) setPhotoAttributionText:(NSString*)text
{
    _photoAttributionText = text;
	[_defaults setObject:text forKey:@"AAPhotoAttributionText"];
    [_defaults synchronize];
    
}

- (NSString*)photoAttributionText
{
    return [_defaults objectForKey:@"AAPhotoAttributionText"];

}

- (void) setPhotoAttributionURL:(NSString*)url
{
    _photoAttributionURL = url;
	[_defaults setObject:url forKey:@"AAPhotoAttributionURL"];
    [_defaults synchronize];
    
}

- (NSString*)photoAttributionURL
{
    return [_defaults objectForKey:@"AAPhotoAttributionURL"];
}

- (void) setCommentName:(NSString *)commentName
{
    _commentName = commentName;
	[_defaults setObject:commentName forKey:@"AACommentName"];
    [_defaults synchronize];
    
}

- (NSString*)commentName
{
    return [_defaults objectForKey:@"AACommentName"];
    
}

- (void) setCommentEmail:(NSString *)commentEmail
{
    _commentEmail = commentEmail;
	[_defaults setObject:commentEmail forKey:@"AACommentEmail"];
    [_defaults synchronize];
    
}

- (NSString*)commentEmail
{
    return [_defaults objectForKey:@"AACommentEmail"];
    
}

- (void) setCommentUrl:(NSString *)commentUrl
{
    _commentUrl = commentUrl;
	[_defaults setObject:commentUrl forKey:@"AACommentUrl"];
    [_defaults synchronize];
    
}

- (NSString*)commentUrl
{
    return [_defaults objectForKey:@"AACommentUrl"];
    
}

- (void) setFlashMode:(NSNumber *)flashMode
{
    _flashMode = flashMode;
	[_defaults setObject:flashMode forKey:@"AACameraFlashMode"];
    [_defaults synchronize];
    
}

- (NSNumber*) flashMode
{
    return [_defaults objectForKey:@"AACameraFlashMode"];
}

#pragma mark - Filter Methods

- (void)setSelectedFilterType:(FilterType)aFilterType
{
	_selectedFilterType = aFilterType;
	[_defaults setInteger:aFilterType forKey:@"AAFilterType"];
}

- (FilterType)selectedFilterType
{
	if (_selectedFilterType == FilterTypeUnchosen) {
		_selectedFilterType = (int)[_defaults integerForKey:@"AAFilterType"];
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
		[_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeFavorites]];
        [_defaults setObject:nil forKey:[self keyForFilterType:FilterTypeCategory]];
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
//	[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:NO];
	
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
//		[ASIHTTPRequest setShouldUpdateNetworkActivityIndicator:YES];
	}
}

#pragma mark - device methods

//determines if the current iOS is 5.0 or higher
+ (BOOL) is5OrHigher 
{
	return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0");
}

//determines if the current iOS is 6.0 or higher
+ (BOOL) is6OrHigher
{
	return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0");
}

//determines if the current iOS is 7.0 or higher
+ (BOOL) is7OrHigher
{
	return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0");
}

//determins if the screen is retina
+ (BOOL) isRetinaDisplay
{
    return ([UIScreen mainScreen].scale > 1);
}

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

#pragma mark - Navigation Bar Helpers
+ (void)showLogoView:(BOOL)show inNavigationBar:(UINavigationBar *)navBar
{
	const int logoViewTag = 123;
	UIImageView *logoView = (UIImageView *)[navBar viewWithTag:logoViewTag];
	
	//if the logoview doesn't exist yet, add the logo to the navigation bar
	if (!logoView) {
		UIImage *logo = [UIImage imageNamed:@"ArtAroundLogo.png"];
		UIImageView *logoView = [[UIImageView alloc] initWithImage:logo];
		[logoView setFrame:CGRectMake(0.0f, 0.0f, logo.size.width, logo.size.height)];
		[logoView setCenter:CGPointMake(navBar.center.x, logoView.center.y)];
		[logoView setContentMode:UIViewContentModeScaleAspectFit];
		[logoView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[logoView setTag:logoViewTag];
		[navBar addSubview:logoView];
	}
	
	//start animation block
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];
	
	//show/hide the logoview
	[logoView setAlpha:show];
	
	//end animation block
    [UIView commitAnimations];
}

#pragma mark analytics

+ (void) trackPageViewWithHierarch:(NSArray*)pageHierarchy
{
    
    NSString *str = @"/aaiOS";
    for (NSString *pageName in pageHierarchy) {
        
//        if ([kViewNamesDictionary objectForKey:pageName])
//            pageName = [kViewNamesDictionary objectForKey:pageName];
        
        str = [NSString stringWithFormat:@"%@/%@", str, pageName];
    }
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:str];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void) trackPageViewWithName:(NSString*)pageName
{
    
//    if ([kViewNamesDictionary objectForKey:pageName])
//        pageName = [kViewNamesDictionary objectForKey:pageName];
    
    id<GAITracker> tracker = [GAI sharedInstance].defaultTracker;
    [tracker set:kGAIScreenName value:[NSString stringWithFormat:@"/aaiOS/%@/", pageName, nil]];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

+ (void) trackEvent:(NSString*)event action:(NSString*)action label:(NSString*)l
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:event
                                                          action:action
                                                           label:l
                                                           value:0] build]];
}

#pragma mark string helper

- (CGSize)frameForText:(NSString*)text sizeWithFont:(UIFont*)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = lineBreakMode;
    
    NSDictionary * attributes = @{NSFontAttributeName:font,
                                  NSParagraphStyleAttributeName:paragraphStyle
                                  };
    
    
    CGRect textRect = [text boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil];
    
    return textRect.size;
}

@end
