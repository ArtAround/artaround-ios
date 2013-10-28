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
#define kBoldDetailFont [UIFont fontWithName:@"Helvetica-Bold" size:13]
#define kBoldItalicDetailFont [UIFont fontWithName:@"Helvetica-BoldOblique" size:13]
#define kDetailFont [UIFont fontWithName:@"Helvetica" size:13]
#define kButtonFont [UIFont fontWithName:@"Verdana-Bold" size:12.0]

//bg colors
#define kBGdarkBrown [UIColor colorWithRed:82.0f/255.0f green:74.0f/255.0f blue:75.0f/255.0f alpha:1.0f]
#define kBGBrown [UIColor colorWithRed:112.0f/255.0f green:101.0f/255.0f blue:103.0f/255.0f alpha:1.0f]
#define kBGlightBrown [UIColor colorWithRed:192.0f/255.0f green:185.0f/255.0f blue:183.0f/255.0f alpha:1.0f]
#define kBGoffWhite [UIColor colorWithRed:(210.0/255.0) green:(210.0/255.0) blue:(210.0/255.0) alpha:1]
#define kLightGray [UIColor colorWithRed:(204.0/255.0) green:(204.0/255.0) blue:(204.0/255.0) alpha:1]
#define kDarkGray [UIColor colorWithRed:(125.0/255.0) green:(126.0/255.0) blue:(121.0/255.0) alpha:1]

//font colors
#define kFontColorDarkBrown [UIColor blackColor]
#define kFontColorBrown [UIColor colorWithRed:193.0f/255.0f green:193.0f/255.0f blue:193.0f/255.0f alpha:1.0f]

//button colors
#define kButtonColorNormal [UIColor colorWithRed:(196.0/255.0) green:(199.0/255.0) blue:(47.0/255.0) alpha:1]
#define kButtonColorHighlighted [UIColor colorWithWhite:1.0f alpha:1.0f]

//System Versioning Preprocessor Macros
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

typedef enum {
	FilterTypeNone = 0,
    FilterTypeFavorites = 1,
	FilterTypeCategory = 2,
	FilterTypeTitle = 3,
	FilterTypeArtist = 4
} FilterType;

@interface Utilities : NSObject
{

	NSUserDefaults *_defaults;
	int _activityCount;
}

@property (nonatomic, assign) FilterType selectedFilterType;
@property (nonatomic, assign) NSDate *lastFlickrUpdate;
@property (nonatomic, assign) NSString *photoAttributionText, *photoAttributionURL, *commentName, *commentEmail, *commentUrl;
@property (nonatomic, assign) NSNumber *flashMode;
@property (nonatomic, retain) NSDictionary *keysDict;
@property BOOL hasLoadedBefore;

+ (Utilities *)instance;
+ (void)zoomToFitMapAnnotations:(MKMapView *)mapView;
- (NSArray *)getFiltersForFilterType:(FilterType)filterType;
- (void)setFilters:(NSArray *)filters forFilterType:(FilterType)filterType;
- (void)startActivity;
- (void)stopActivity;
+ (BOOL) is5OrHigher;
+ (BOOL) is6OrHigher;
+ (BOOL) is7OrHigher;
+ (BOOL) isRetinaDisplay;
+ (BOOL)isNewHardware;
+ (void)showLogoView:(BOOL)show inNavigationBar:(UINavigationBar *)navBar;
+ (NSString *)urlEncode:(NSString *)string;
+ (NSString *)urlDecode:(NSString *)string;
+ (void) trackPageViewWithHierarch:(NSArray*)pageHierarchy;
+ (void) trackPageViewWithName:(NSString*)pageName;
+ (void) trackEvent:(NSString*)event action:(NSString*)action label:(NSString*)l;

@end
