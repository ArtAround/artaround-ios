//
//  ArtAroundAppDelegate.h
//  ArtAround
// 
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "IntroViewController.h"

#define kGoogleAnalyticsAccountID @"UA-41817858-1"
// Dispatch period in seconds
static const NSInteger kGANDispatchPeriodSec = 10;

@interface ArtAroundAppDelegate : NSObject <UIApplicationDelegate>
{
    IntroViewController *_introVC;
}

@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) MapViewController *mapViewController;
//@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
//@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
//@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//- (void)saveContext;
//- (NSURL *)applicationDocumentsDirectory;
- (void) closeIntro;

@end
