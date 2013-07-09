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

@property (nonatomic, assign) Art *art;
@property (retain, nonatomic) IBOutlet UILabel *artNameLabel;
@property (retain, nonatomic) IBOutlet EGOImageView *artImageView;
@property (retain, nonatomic) IBOutlet UILabel *artDistanceLabel;
@property (retain, nonatomic) IBOutlet UILabel *artistLabel;
@property (retain, nonatomic) IBOutlet UILabel *yearLabel;


- (void)setArt:(Art *)theArt;
- (void)setupImage;
@end
