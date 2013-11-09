//
//  PhotoImageView.h
//  ArtAround
//
//  Created by Brian Singer on 5/4/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "EGOImageView.h"
#define kAttributionButtonLabelTag 55

@protocol PhotoImageViewDelegate;

@interface PhotoImageView : EGOImageView

@property (nonatomic, weak) id <PhotoImageViewDelegate> photoImageViewDelegate;
@property (nonatomic, strong) UIButton *photoAttributionButton;
@property (nonatomic, strong) NSURL *url;
@end

@protocol PhotoImageViewDelegate

- (void) attributionButtonPressed:(id)sender withTitle:(NSString*)title andURL:(NSURL*)url;

@end

