//
//  AddDetailViewController.h
//  ArtAround
//
//  Created by Brian Singer on 1/21/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "DetailViewController.h"

@interface AddDetailViewController : DetailViewController <UIActionSheetDelegate>
{
}

@property (nonatomic, retain) CLLocation *currentLocation;

@end
