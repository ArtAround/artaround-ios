//
//  PhotoImageView.h
//  ArtAround
//
//  Created by Brian Singer on 5/4/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import "EGOImageView.h"

@interface PhotoImageView : EGOImageView

@property (nonatomic, retain) UILabel *photoAttributionLabel;
@property (nonatomic, retain) UIButton *photoAttributionButton;

@end
