//
//  PhotoImageView.m
//  ArtAround
//
//  Created by Brian Singer on 5/4/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "PhotoImageView.h"

#define kLabelHeight 25.0f

@implementation PhotoImageView

@synthesize photoAttributionButton, photoAttributionLabel;
@synthesize photoImageViewDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIButton *attributionButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0f, frame.size.height - kLabelHeight - 10.0f, frame.size.width - 20.0f, kLabelHeight)];
//        [attributionButton setFrame:CGRectMake(10.0f, frame.size.height - kLabelHeight - 10.0f, frame.size.width - 20.0f, kLabelHeight)];

        [attributionButton setBackgroundImage:[UIImage imageNamed:@"FilterBackgroundPressed.png"] forState:UIControlStateHighlighted];
        [attributionButton setBackgroundImage:[UIImage imageNamed:@"FilterBackground.png"] forState:UIControlStateNormal];
//        [attributionButton setBackgroundColor:[UIColor clearColor]];
        [attributionButton setTitleEdgeInsets:UIEdgeInsetsZero];
        [attributionButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        [attributionButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [attributionButton addTarget:self action:@selector(attributionButtonPressed) forControlEvents:UIControlEventTouchUpInside];

        [self setPhotoAttributionButton:attributionButton];
        
        //add label to button
        UILabel *attributionButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, attributionButton.frame.size.width, attributionButton.frame.size.height)];
        [attributionButtonLabel setBackgroundColor:[UIColor blueColor]];
        [attributionButtonLabel setText:@"Att Button"];
        [attributionButtonLabel setTag:kAttributionButtonLabelTag];
        [attributionButtonLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        [attributionButtonLabel setTextColor:[UIColor whiteColor]];
        [attributionButtonLabel setTextAlignment:NSTextAlignmentLeft];
        [attributionButton addSubview:attributionButtonLabel];
        
        UILabel *attributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, attributionButton.frame.origin.y - kLabelHeight, frame.size.width - 20.0f, kLabelHeight)];
        [attributionLabel setBackgroundColor:[UIColor clearColor]];
        [attributionLabel setText:@"Att Label"];
        [attributionLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        [attributionLabel setTextColor:[UIColor whiteColor]];
        [attributionLabel setTextAlignment:NSTextAlignmentLeft];
        [self setPhotoAttributionLabel:attributionLabel];
        
        [self addSubview:self.photoAttributionLabel];
        [self addSubview:self.photoAttributionButton];
        
        DebugLog(@"Label Width: %f", self.photoAttributionLabel.frame.size.width);
    }
    return self;
}

- (void) attributionButtonPressed {

    if (self.photoImageViewDelegate && [(id)self.photoImageViewDelegate performSelector:@selector(attributionButtonPressed:)])
        [(id)self.photoImageViewDelegate attributionButtonPressed:self];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (UIView*) hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    CGPoint touchPoint = [self.photoAttributionButton convertPoint:point fromView:self];

    if ([self.photoAttributionButton pointInside:touchPoint withEvent:event]) {
        return self.photoAttributionButton;
    }
    
    return [super hitTest:point withEvent:event];
    
    
}
@end
