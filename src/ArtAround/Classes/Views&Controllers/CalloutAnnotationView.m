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

@interface CalloutAnnotationView (private)
- (void)preventParentSelectionChange;
@end

@implementation CalloutAnnotationView
@synthesize coordinate = _coordinate, art = _art, button = _button, parentAnnotationView = _parentAnnotationView, mapView = _mapView;

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
		
    }
    
    return self;
}

- (void)dealloc
{
	[self setButton:nil];
	[super dealloc];
}

- (void)setArt:(Art *)art
{
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
