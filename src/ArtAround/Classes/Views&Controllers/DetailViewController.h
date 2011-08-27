//
//  DetailViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Art;

@interface DetailViewController : UIViewController
{
	Art *_art;
}

- (id)initWithArt:(Art *)art;

@end
