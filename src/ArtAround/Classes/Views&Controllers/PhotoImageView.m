//
//  PhotoImageView.m
//  ArtAround
//
//  Created by Brian Singer on 5/4/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "PhotoImageView.h"
#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>

#define kLabelHeight 25.0f

@implementation PhotoImageView

@synthesize photoAttributionButton;
@synthesize photoImageViewDelegate;
@synthesize url = _url;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIImage *buttonArrowImage = [UIImage imageNamed:@"buttonArrow.png"];
        UIButton *attributionButton = [[UIButton alloc] initWithFrame:CGRectMake(-2.0f, frame.size.height - kLabelHeight - 20.0f, frame.size.width + 2.0f   , kLabelHeight + 20)];
        [attributionButton setBackgroundImage:[UIImage imageNamed:@"FilterBackgroundPressed.png"] forState:UIControlStateNormal];
        [attributionButton setTitleEdgeInsets:UIEdgeInsetsZero];
        [attributionButton setAdjustsImageWhenHighlighted:NO];
        [attributionButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        [attributionButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [attributionButton addTarget:self action:@selector(attributionButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [attributionButton setImageEdgeInsets:UIEdgeInsetsMake(0, self.frame.size.width - buttonArrowImage.size.width, 0, 0.0f)];

        [self setPhotoAttributionButton:attributionButton];
        
        //add label to button
        UILabel *attributionButtonLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0, attributionButton.frame.size.width - buttonArrowImage.size.width, attributionButton.frame.size.height)];
        [attributionButtonLabel setBackgroundColor:[UIColor clearColor]];
        [attributionButtonLabel setText:@"Photo by"];
        [attributionButtonLabel setFont:kButtonFont];
        [attributionButtonLabel setTextColor:kButtonColorNormal];
        [attributionButtonLabel setHighlightedTextColor:kButtonColorHighlighted];
        [attributionButtonLabel setTag:kAttributionButtonLabelTag];
        [attributionButtonLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth];
        [attributionButtonLabel setTextAlignment:NSTextAlignmentLeft];
        [attributionButton addSubview:attributionButtonLabel];

        [self addSubview:self.photoAttributionButton];
        
    }
    return self;
}

- (void) attributionButtonPressed {

    if (_url && _url.absoluteString.length > 0) {
        
        [(id)self.photoImageViewDelegate attributionButtonPressed:self withTitle:self.photoAttributionButton.titleLabel.text andURL:_url];
        
    }
    
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
    NSString *urlString = [(UILabel*)[self.photoAttributionButton viewWithTag:kAttributionButtonLabelTag] text];
    
    if (urlString && urlString.length > 0) {
        
        CGPoint touchPoint = [self.photoAttributionButton convertPoint:point fromView:self];
        
        if ([self.photoAttributionButton pointInside:touchPoint withEvent:event]) {
            return self.photoAttributionButton;
        }
        
    }
    return [super hitTest:point withEvent:event];
    
    
}

- (void) setUrl:(NSURL *)newUrl
{
    if (!newUrl) return;
    
    if (newUrl.absoluteString.length > 0) {
        
        _url = [newUrl retain];
        
        UIImage *buttonArrowImage = [UIImage imageNamed:@"buttonArrow.png"];
        UIImage *buttonArrowImageWhite = [UIImage imageNamed:@"buttonArrowWhite.png"];
        
        [self.photoAttributionButton setImage:buttonArrowImage forState:UIControlStateNormal];
        [self.photoAttributionButton setImage:buttonArrowImageWhite forState:UIControlStateHighlighted];
        [self.photoAttributionButton setAdjustsImageWhenHighlighted:YES];
    }
}

- (NSURL*) url {
    return _url;
}
@end
