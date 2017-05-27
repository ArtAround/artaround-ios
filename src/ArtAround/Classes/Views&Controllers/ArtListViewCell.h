//
//  ArtListViewCell.h
//  ArtAround
//
//  Created by Brian Singer on 3/5/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"
#import "Art.h"

@interface ArtListViewCell : UITableViewCell

@property (nonatomic, weak) Art *art;
@property (strong, nonatomic) IBOutlet UILabel *artNameLabel;
@property (strong, nonatomic) IBOutlet EGOImageView *artImageView;
@property (strong, nonatomic) IBOutlet UILabel *artDistanceLabel;
@property (strong, nonatomic) IBOutlet UILabel *artistLabel;
@property (strong, nonatomic) IBOutlet UILabel *yearLabel;


- (void)setArt:(Art *)theArt;
- (void)setupImage;
@end
