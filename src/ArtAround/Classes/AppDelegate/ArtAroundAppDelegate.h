//
//  ArtAroundAppDelegate.h
//  ArtAround
// 
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "FBConnect.h"
#import "IntroViewController.h"

#define kGoogleAnalyticsAccountID @"UA-19074200-1"
// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@interface ArtAroundAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>
{
    IntroViewController *_introVC;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) MapViewController *mapViewController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Facebook *facebook;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void) closeIntro;

@end
