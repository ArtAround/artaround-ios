//
//  DetailViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DetailView;
@class Art;

@interface DetailViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) DetailView *detailView;
@property (nonatomic, assign) Art *art;

@end
