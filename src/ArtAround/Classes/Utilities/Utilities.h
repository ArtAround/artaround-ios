//
//  Utilities.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MKMapView;


//font types
#define kH1Font [UIFont fontWithName:@"Georgia-Bold" size:16]
#define kH2Font [UIFont fontWithName:@"Georgia-BoldItalic" size:14]
#define kBoldDetailFont [UIFont fontWithName:@"Helvetica-Bold" size:11]
#define kBoldItalicDetailFont [UIFont fontWithName:@"Helvetica-BoldOblique" size:11]
#define kDetailFont [UIFont fontWithName:@"Helvetica" size:11]

//bg colors
#define kBGdarkBrown [UIColor colorWithRed:82.0f/255.0f green:74.0f/255.0f blue:75.0f/255.0f alpha:1.0f]
#define kBGBrown [UIColor colorWithRed:112.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]
#define kBGlightBrown [UIColor colorWithRed:192.0f/255.0f green:185.0f/255.0f blue:183.0f/255.0f alpha:1.0f]
#define kBGoffWhite [UIColor colorWithRed:(233.0/255.0) green:(234.0/255.0) blue:(228.0/255.0) alpha:1]

//font colors
#define kFontColorDarkBrown [UIColor colorWithRed:49.0f/255.0f green:45.0f/255.0f blue:45.0f/255.0f alpha:1.0f]
#define kFontColorBrown [UIColor colorWithRed:82.0f/255.0f green:74.0f/255.0f blue:74.0f/255.0f alpha:1.0f]


//System Versioning Preprocessor Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef enum {
	FilterTypeNone = 0,
    FilterTypeRank = 1,
	FilterTypeCategory = 2,
	FilterTypeNeighborhood = 3,
	FilterTypeTitle = 4,
	FilterTypeArtist = 5,
    FilterTypeEvent = 6
} FilterType;

@interface Utilities : NSObject
{

	NSUserDefaults *_defaults;
	int _activityCount;
}

@property (nonatomic, assign) FilterType selectedFilterType;
@property (nonatomic, assign) NSDate *lastFlickrUpdate;
@property (nonatomic, assign) NSString *flickrHandle;
@property (nonatomic, retain) NSDictionary *keysDict;
@property BOOL hasLoadedBefore;

+ (Utilities *)instance;
+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView;
- (NSArray *)getFiltersForFilterType:(FilterType)filterType;
- (void)setFilters:(NSArray *)filters forFilterType:(FilterType)filterType;
- (void)startActivity;
- (void)stopActivity;
+ (BOOL) is5OrHigher;
+ (BOOL) isRetinaDisplay;
+ (BOOL)isNewHardware;
+ (void)showLogoView:(BOOL)show inNavigationBar:(UINavigationBar *)navBar;
+ (NSString *)urlEncode:(NSString *)string;
+ (NSString *)urlDecode:(NSString *)string;
+ (void) trackPageViewWithHierarch:(NSArray*)pageHierarchy;
+ (void) trackPageViewWithName:(NSString*)pageName;
+ (void) trackEvent:(NSString*)event action:(NSString*)action label:(NSString*)label value:(NSInteger*)value;

@end
