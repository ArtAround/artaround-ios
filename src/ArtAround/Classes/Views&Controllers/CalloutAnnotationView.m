//
//  CalloutAnnotationView.m
//  ArtAround
//
//  Created by Brandon Jones on 8/30/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "CalloutAnnotationView.h"
#import "Art.h"
#import "ArtAnnotation.h"
#import "ArtAnnotationView.h"
#import "Category.h"
#import "Photo.h"
#import "EGOImageView.h"
#import "FlickrAPIManager.h"
#import <QuartzCore/QuartzCore.h>

@interface CalloutAnnotationView (private)
- (void)preventParentSelectionChange;
- (void)setupImage;
@end

@implementation CalloutAnnotationView
@synthesize coordinate = _coordinate, art = _art, parentAnnotationView = _parentAnnotationView, mapView = _mapView;
@synthesize button = _button, imageView = _imageView, titleLabel = _titleLabel, artistLabel = _artistLabel, categoryLabel = _categoryLabel, summaryLabel = _summaryLabel;

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate frame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		[self setCoordinate:theCoordinate];
		
		//image view
		UIImage *image = [UIImage imageNamed:@"ItemBubble.png"];
		UIImage *imageHighlighted = [UIImage imageNamed:@"ItemBubblePressed.png"];
		UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[aButton setBackgroundImage:image forState:UIControlStateNormal];
		[aButton setBackgroundImage:imageHighlighted forState:UIControlStateHighlighted];
		[aButton setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
		[self setButton:aButton];
		[self addSubview:self.button];
		
		//image
		EGOImageView *anImageView = [[EGOImageView alloc] initWithPlaceholderImage:nil];
		[anImageView setContentMode:UIViewContentModeScaleAspectFill];
		[anImageView setClipsToBounds:YES];
		[anImageView setBackgroundColor:[UIColor lightGrayColor]];
		[anImageView setFrame:CGRectMake(13.0f, 13.0f, 100.0f, 100.0f)];
		[anImageView.layer setBorderWidth:2.0f];
		[anImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
		[self setImageView:anImageView];
		[self addSubview:self.imageView];
		[anImageView release];
		
		//title
		UILabel *aTitleLabel = [[UILabel alloc] init];
		[aTitleLabel setFont:[UIFont fontWithName:@"Georgia-Bold" size:13.0f]];
		[aTitleLabel setBackgroundColor:[UIColor clearColor]];
		[self setTitleLabel:aTitleLabel];
		[self addSubview:self.titleLabel];
		[aTitleLabel release];
	
		//artist
		UILabel *anArtistLabel = [[UILabel alloc] init];
		[anArtistLabel setFont:[UIFont fontWithName:@"Helvetica" size:9.25f]];
		[anArtistLabel setBackgroundColor:[UIColor clearColor]];
		[self setArtistLabel:anArtistLabel];
		[self addSubview:self.artistLabel];
		[anArtistLabel release];
		
		//category
		UILabel *aCategoryLabel = [[UILabel alloc] init];
		[aCategoryLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:9.25f]];
		[aCategoryLabel setBackgroundColor:[UIColor clearColor]];
		[self setCategoryLabel:aCategoryLabel];
		[self addSubview:self.categoryLabel];
		[aCategoryLabel release];
		
		//summary
		UILabel *aSummaryLabel = [[UILabel alloc] init];
		[aSummaryLabel setFont:[UIFont fontWithName:@"Helvetica" size:9.25f]];
		[aSummaryLabel setBackgroundColor:[UIColor clearColor]];
		[aSummaryLabel setNumberOfLines:3];
		[self setSummaryLabel:aSummaryLabel];
		[self addSubview:self.summaryLabel];
		[aSummaryLabel release];

    }
    
    return self;
}

- (void)dealloc
{
	[self setButton:nil];
	[self setImageView:nil];
	[self setTitleLabel:nil];
	[self setArtistLabel:nil];
	[self setCategoryLabel:nil];
	[self setSummaryLabel:nil];
	[super dealloc];
}

- (void)prepareForReuse
{
	[self setArt:nil];
}

- (void)setArt:(Art *)art
{
	//assign the art
	_art = art;

	//if art is nil, reset everything
	if (!_art) {
		[self.imageView setImageURL:nil];
		[self.titleLabel setText:@""];
		[self.artistLabel setText:@""];
		[self.categoryLabel setText:@""];
		[self.summaryLabel setText:@""];
		return;
	}

	//grab the first photo and either set the url or download the deets from flickr
	if (_art.photos && [_art.photos count] > 0) {
		Photo *photo = [[_art.photos allObjects] objectAtIndex:0];
		if (photo.smallSource && ![photo.smallSource isEqualToString:@""]) {
			[self setupImage];
		} else {
			[[FlickrAPIManager instance] downloadPhotoWithID:photo.flickrID target:self callback:@selector(setupImage)];
		}
	}
	
	//are the fields empty?
	BOOL showTitle = _art.title && ![_art.title isEqualToString:@""];
	BOOL showArtist = _art.artist && ![_art.artist isEqualToString:@""];
	BOOL showYear = _art.year && ![_art.year intValue] == 0;
	
	//artist label is a concatenation of artist - year
	NSString *artist = @"";
	if (showArtist && showYear) {
		artist = [NSString stringWithFormat:@"%@ - %@", _art.artist, _art.year];
	} else if (showArtist && !showYear) {
		artist = _art.artist;
	} else if (!showArtist && showYear) {
		artist = [_art.year stringValue];
	}
	
	//set label text
	[self.titleLabel setText:_art.title];
	[self.artistLabel setText:artist];
	[self.categoryLabel setText:_art.category.title];
	[self.summaryLabel setText:_art.locationDescription];
	
	//update frames
	const float padding = 10.0f;
	float yOffset = self.imageView.frame.origin.y;
	[self.titleLabel setFrame:CGRectMake(self.imageView.frame.origin.x + self.imageView.frame.size.width + padding, yOffset, 185.0f, 20.0f)];
	yOffset = (showTitle) ? self.titleLabel.frame.origin.y + self.titleLabel.frame.size.height : yOffset;
	[self.artistLabel setFrame:CGRectMake(self.titleLabel.frame.origin.x, yOffset, self.titleLabel.frame.size.width, 15.0f)];
	yOffset = (showArtist) ? self.artistLabel.frame.origin.y + self.artistLabel.frame.size.height : yOffset;
	[self.categoryLabel setFrame:CGRectMake(self.artistLabel.frame.origin.x, yOffset, self.titleLabel.frame.size.width, 15.0f)];
	[self.summaryLabel setFrame:CGRectMake(self.categoryLabel.frame.origin.x, 63.0f, self.titleLabel.frame.size.width, 50.0f)];
	
}

- (void)setupImage
{
	if (_art.photos && [_art.photos count] > 0) {
		Photo *photo = [[_art.photos allObjects] objectAtIndex:0];
		if (photo.smallSource && ![photo.smallSource isEqualToString:@""]) {
			[self.imageView setImageURL:[NSURL URLWithString:photo.smallSource]];
		}
	}
}

#pragma mark - enable / disable parent and siblings
//the following code allows the showing and tapping of the custom callout without it disappearing

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self.button) {
		
        [self preventParentSelectionChange];
        [self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:0.8];
        for (UIView *sibling in self.superview.subviews) {
            if ([sibling isKindOfClass:[MKAnnotationView class]]) {// && sibling != self.parentAnnotationView) {
                ((MKAnnotationView *)sibling).enabled = NO;
                [self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:0.8];
            }
        }
		
    } else if (!self.parentAnnotationView.preventSelectionChange) {
		
		//reset the coordinate and hide the callout
		CLLocationCoordinate2D coord;
		coord.latitude = 0;
		coord.longitude = 0;
		[self setCoordinate:coord];
		[self.mapView deselectAnnotation:self animated:NO];
		
	}
	
    return hitView;
}

- (void)enableSibling:(UIView *)sibling
{
    ((MKAnnotationView *)sibling).enabled = YES;
}

- (void)preventParentSelectionChange
{
    self.parentAnnotationView.preventSelectionChange = YES;
}

- (void)allowParentSelectionChange
{
	[self.mapView selectAnnotation:self.parentAnnotationView.annotation animated:NO];
    self.parentAnnotationView.preventSelectionChange = NO;
}

@end
