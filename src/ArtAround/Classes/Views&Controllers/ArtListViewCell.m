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
#import <QuartzCore/QuartzCore.h>

#define kArtAroundURL @"http://www.theartaround.us"
//#define kArtAroundURL @"http://staging.theartaround.us"

@implementation ArtListViewCell
@synthesize artNameLabel;
@synthesize artImageView;
@synthesize artDistanceLabel;
@synthesize artistLabel;
@synthesize yearLabel;
@synthesize art = _art;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //cell props
        //self.contentView.backgroundColor = [UIColor colorWithRed:(204.0f/255.0f) green:(204.0f/255.0f) blue:(204.0f/255.0f) alpha:1.0f];
        self.selectionStyle = UITableViewCellSelectionStyleGray;
        
        
        
        //image
        artImageView = [[EGOImageView alloc] initWithFrame:CGRectMake(7, 7, 72, 72)];
        [artImageView setContentMode:UIViewContentModeScaleAspectFill];
        [artImageView setBackgroundColor:[UIColor grayColor]];
        [artImageView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
        [artImageView setClipsToBounds:YES];
        [artImageView.layer setBorderColor:[UIColor whiteColor].CGColor];
        [artImageView.layer setBorderWidth:2.0f];

        
        //name label
        artNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 7, 175, 38)];
        artNameLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;        
        artNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
        artNameLabel.numberOfLines = 2;
        artNameLabel.backgroundColor = [UIColor clearColor];
        artNameLabel.textColor = kFontColorDarkBrown;
        
        //name label
        artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 43, 181, 15)];
        artistLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        artistLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        artistLabel.backgroundColor = [UIColor clearColor];
        artistLabel.textColor = [UIColor grayColor];
        
        //name label
        yearLabel = [[UILabel alloc] initWithFrame:CGRectMake(86, 58, 181, 15)];
        yearLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        yearLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
        yearLabel.backgroundColor = [UIColor clearColor];
        yearLabel.textColor = [UIColor grayColor];
        
        
        //dist
        artDistanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(267, 10, 44, 11)];
        artDistanceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:10];
        artDistanceLabel.backgroundColor = [UIColor clearColor];
        artDistanceLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        artDistanceLabel.textColor = kFontColorDarkBrown;
        
        [self.contentView addSubview:artImageView];
        [self.contentView addSubview:artNameLabel];
        [self.contentView addSubview:artistLabel];
        [self.contentView addSubview:yearLabel];
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
        
		return;
	}
    
    //clear the old image
    [self.artImageView setImage:nil];
    
	//grab the first photo and either set the url or download the deets from flickr
	if (self.art.photos && [self.art.photos count] > 0) {
		Photo *photo = [[self.art.photos allObjects] objectAtIndex:0];
		if (photo.mediumURL && ![photo.mediumURL isEqualToString:@""]) {
			
            [self.artImageView setImageURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kArtAroundURL, photo.mediumURL]]];
            
		} else {
			
			[[AAAPIManager instance] downloadArtForSlug:self.art.slug target:self callback:@selector(setupImage) forceDownload:YES];
		}
	}
    else {
        [self.artImageView setImage:nil];
        [[AAAPIManager instance] downloadArtForSlug:self.art.slug target:self callback:@selector(setupImage) forceDownload:YES];
    }
	
	
	//set label text
	[self.artNameLabel setText:self.art.title];
    
    CGSize titleSize = [self.art.title sizeWithFont:self.artNameLabel.font constrainedToSize:CGSizeMake(self.artNameLabel.frame.size.width, (self.artNameLabel.font.lineHeight * 2.0f)) lineBreakMode:NSLineBreakByWordWrapping];
    DebugLog(@"titleSize: %f, %f", titleSize.width, titleSize.height);
    DebugLog(@"lineHeight: %f", artNameLabel.font.lineHeight);
    
    [self.artNameLabel setFrame:CGRectMake(self.artNameLabel.frame.origin.x, self.artNameLabel.frame.origin.y, self.artNameLabel.frame.size.width, titleSize.height)];
    
    //set artist and year text and set frames
    NSString *artistString = ([self.art.artist isEqualToString:@"Unknown"]) ? @"" : self.art.artist;
    [self.artistLabel setText:artistString];
    CGSize artistSize = [artistString sizeWithFont:self.artistLabel.font constrainedToSize:self.artistLabel.frame.size lineBreakMode:NSLineBreakByWordWrapping];
    [self.artistLabel setFrame:CGRectMake(self.artistLabel.frame.origin.x, self.artNameLabel.frame.origin.y + self.artNameLabel.frame.size.height + 3.0f, self.artistLabel.frame.size.width, artistSize.height)];
    
    NSString *yearString = ([[self.art.year stringValue] isEqualToString:@"0"]) ? @"" : [self.art.year stringValue];
    [self.yearLabel setText:yearString];
    CGSize yearSize = [yearString sizeWithFont:self.yearLabel.font constrainedToSize:self.yearLabel.frame.size lineBreakMode:NSLineBreakByWordWrapping];
    [self.yearLabel setFrame:CGRectMake(self.yearLabel.frame.origin.x, self.artistLabel.frame.origin.y + self.artistLabel.frame.size.height, self.yearLabel.frame.size.width, yearSize.height)];
    
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
    [artistLabel release];
    [yearLabel release];
    [super dealloc];
}
@end
