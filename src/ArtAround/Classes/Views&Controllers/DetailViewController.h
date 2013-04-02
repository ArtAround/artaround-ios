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
#import "FlagViewController.h"
#import "FlickrNameViewController.h"
@class DetailView;
@class Art;

#define kHorizontalPadding 10.0f

typedef enum AAShareType {
	AAShareTypeEmail = 0,
    AAShareTypeTwitter = 1,
	AAShareTypeFacebook = 2
} AAShareType;

@interface DetailViewController : UIViewController <UIWebViewDelegate, MKMapViewDelegate, UIActionSheetDelegate, FBDialogDelegate, FBSessionDelegate, MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextViewDelegate, FlagViewControllerDelegate, FlickrNameViewControllerDelegate>
{
	ArtAroundAppDelegate*  _appDelegate;
	Facebook*              _facebook;
    BOOL                   _inEditMode, _showAllComments;    
    UIAlertView*           _loadingAlertView;    
    NSMutableArray*        _userAddedImages;
    NSMutableDictionary*   _newArtDictionary, *_newCommentDictionary;
    int                    _addedImageCount;
    UITextField*           _artNameField, *_categoryField, *_artistField, *_yearField, *_neighborhoodField, *_wardField;
    UITextView*            _artDescriptionView, *_locationDescriptionView;
    UIButton*              _invBackButton;
    
}

- (void)setArt:(Art *)art withTemplate:(NSString*)templateFileName;
- (void)setArt:(Art *)art withTemplate:(NSString*)templateFileName forceDownload:(BOOL)force;
- (void)setInEditMode:(BOOL)editMode;
- (void)bottomToolbarButtonTapped;
- (void)userAddedImage:(UIImage*)image;
- (void)setupImages;


@property (nonatomic, retain) CLLocation *currentLocation;
@property (nonatomic, retain) DetailView *detailView;
@property (nonatomic, assign) Art *art;

@end
