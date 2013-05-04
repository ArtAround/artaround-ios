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

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        UIButton *attributionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [attributionButton setFrame:CGRectMake(10.0f, frame.size.height - kLabelHeight - 10.0f, frame.size.width - 20.0f, kLabelHeight)];
        [attributionButton setTitle:@"Attr Button" forState:UIControlStateNormal];
        [attributionButton setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [self setPhotoAttributionButton:attributionButton];
        
        UILabel *attributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, attributionButton.frame.origin.y - kLabelHeight, frame.size.width - 20.0f, kLabelHeight)];
        [attributionLabel setBackgroundColor:[UIColor clearColor]];
        [attributionLabel setText:@"Att Label"];
        [attributionLabel setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [self setPhotoAttributionLabel:attributionLabel];
        
        [self addSubview:self.photoAttributionLabel];
        [self addSubview:self.photoAttributionButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
