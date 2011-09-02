//
//  ArtAroundAppDelegate.h
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FBConnect.h"

@interface ArtAroundAppDelegate : NSObject <UIApplicationDelegate, FBSessionDelegate>

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain) Facebook *facebook;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
