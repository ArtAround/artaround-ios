//
//  DetailViewController.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MessageUI/MessageUI.h>
#import "ArtAroundAppDelegate.h"
#import "FBConnect.h"
@class DetailView;
@class Art;

typedef enum AAShareType {
	AAShareTypeEmail = 0,
    AAShareTypeTwitter = 1,
	AAShareTypeFacebook = 2
} AAShareType;

@interface DetailViewController : UIViewController <UIWebViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, FBDialogDelegate, FBSessionDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate>
{
	ArtAroundAppDelegate *_appDelegate;
	Facebook *_facebook;
    UIAlertView *_loadingAlertView;    
    NSMutableArray *_userAddedImages;
}

- (void)setArt:(Art *)art withTemplate:(NSString*)templateFileName;
- (void)bottomToolbarButtonTapped;
- (NSString*)buildHTMLString;


@property (nonatomic, retain) DetailView *detailView;
@property (nonatomic, assign) Art *art;

@end
