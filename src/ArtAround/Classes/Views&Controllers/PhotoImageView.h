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

@property (nonatomic, assign) id <PhotoImageViewDelegate> *photoImageViewDelegate;
@property (nonatomic, retain) UILabel *photoAttributionLabel;
@property (nonatomic, retain) UIButton *photoAttributionButton;

@end

@protocol PhotoImageViewDelegate

- (void) attributionButtonPressed:(id)sender withTitle:(NSString*)title andURL:(NSURL*)url;

@end

