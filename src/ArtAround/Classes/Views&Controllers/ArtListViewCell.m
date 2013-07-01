//
//  ArtListViewCell.m
//  ArtAround
//
//  Created by Brian Singer on 3/5/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "ArtListViewCell.h"
#import "Photo.h"
#import "FlickrAPIManager.h"
#import "Category.h"
#import "Utilities.h"
#import "AAAPIManager.h"

//#define kArtAroundURL @"http://www.theartaround.us"
#define kArtAroundURL @"http://staging.theartaround.us"

@implementation ArtListViewCell
@synthesize artNameLabel;
@synthesize artImageBackView;
@synthesize artImageView;
@synthesize artDistanceLabel;
@synthesize art = _art;
@synthesize artDescriptionLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //cell props
        self.contentView.backgroundColor = kBGoffWhite;
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        
        
        //image
        artImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 10, 60, 60)];
        [artImageView setContentMode:UIViewContentModeScaleAspectFill];
        [artImageView setBackgroundColor:[UIColor lightGrayColor]];
        [artImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        [artImageView setClipsToBounds:YES];
        artImageBackView = [[UIView alloc] initWithFrame:CGRectMake(6, 6, 68, 68)];
        [artImageBackView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        [artImageBackView setBackgroundColor:[UIColor whiteColor]];
        
        //name label
        artNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 10, 185, 17)];
        artNameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;        
        artNameLabel.font = [UIFont fontWithName:@"Georgia-Bold" size:14];
        artNameLabel.backgroundColor = [UIColor clearColor];
        artNameLabel.textColor = kFontColorDarkBrown;
        
        //desc
        artDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 25, 220, 43)];
        artDescriptionLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;        
        artDescriptionLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        artDescriptionLabel.numberOfLines = 3;
        artDescriptionLabel.backgroundColor = [UIColor clearColor];
        artDescriptionLabel.textColor = kFontColorDarkBrown;
        
        //dist
        artDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(267, 10, 44, 11)];
        artDistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        artDistanceLabel.backgroundColor = [UIColor clearColor];
        artDistanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        artDistanceLabel.textColor = kFontColorDarkBrown;
        
        [self.contentView addSubview:artImageBackView];
        [self.contentView addSubview:artImageView];
        [self.contentView addSubview:artNameLabel];
        [self.contentView addSubview:artDescriptionLabel];        
        [self.contentView addSubview:artDistanceLabel];        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (void)prepareForReuse
//{
//    [self setArt:nil];
//}

- (void)setArt:(Art *)theArt
{

    _art = theArt;
    
	//if art is nil, reset everything
	if (!self.art) {
		[self.artImageView setImageURL:nil];
		[self.artNameLabel setText:@""];
		[self.artDistanceLabel setText:@""];
		[self.artDescriptionLabel setText:@""];
        
		return;
	}
    
    //clear the old image
    [self.artImageView setImage:nil];
    
	//grab the first photo and either set the url or download the deets from flickr
	if (self.art.photos && [self.art.photos count] > 0) {
		Photo *photo = [[self.art.photos allObjects] objectAtIndex:0];
		if (photo.mediumURL && ![photo.mediumURL isEqualToString:@""]) {
			
//            if (art.photos && [art.photos count] > 0) {
//                Photo *photo = [[art.photos allObjects] objectAtIndex:0];
//                if (photo.smallSource && ![photo.smallSource isEqualToString:@""]) {
                    [self.artImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kArtAroundURL, photo.mediumURL]]];
//                }
//            }
		} else {
			//[[FlickrAPIManager instance] downloadPhotoWithID:photo.flickrID target:self callback:@selector(setupImage)];
			[[AAAPIManager instance] downloadArtForSlug:self.art.slug target:self callback:@selector(setupImage) forceDownload:YES];
		}
	}
    else {
        [self.artImageView setImage:nil];
        [[AAAPIManager instance] downloadArtForSlug:self.art.slug target:self callback:@selector(setupImage) forceDownload:YES];
    }
	
	
	//set label text
	[self.artNameLabel setText:self.art.title];
	[self.artDescriptionLabel setText:self.art.locationDescription];
    
    if (self.art.distance) {
        [self.artDistanceLabel setText:[NSString stringWithFormat:@"%0.2f mi", [self.art.distance doubleValue]]];
    }
	
}

- (void)setupImage
{
	if (self.art.photos && [self.art.photos count] > 0) {
		Photo *photo = [[self.art.photos allObjects] objectAtIndex:0];
		if (photo.mediumURL && ![photo.mediumURL isEqualToString:@""]) {
			[self.artImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kArtAroundURL, photo.mediumURL]]];
		}
	}
}

- (void)dealloc {
    
    [artNameLabel release];
    [artImageView release];
    [artDistanceLabel release];
    [artDescriptionLabel release];
    [artImageBackView release];
    [super dealloc];
}
@end
