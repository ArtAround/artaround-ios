//
//  ArtAroundAppDelegate.m
//  ArtAround
//
//  Created by Brandon Jones on 8/24/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "ArtAroundAppDelegate.h"
#import "MapViewController.h"
#import "AAAPIManager.h"
#import "FlickrAPIManager.h"
#import "Utilities.h"
#import "FBConnect.h"
#import "GANTracker.h"
#import "IntroViewController.h"

@implementation ArtAroundAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize managedObjectContext = __managedObjectContext;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize facebook = _facebook;
@synthesize mapViewController = _mapViewController;
@synthesize lastLocation;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[GANTracker sharedTracker] startTrackerWithAccountID:kGoogleAnalyticsAccountID
                                           dispatchPeriod:kGANDispatchPeriodSec
                                                 delegate:nil];

    
	//initialize the window
	UIWindow *newWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	[self setWindow:newWindow];
	[[self window] setBackgroundColor:[UIColor scrollViewTexturedBackgroundColor]];
	[[self window] makeKeyAndVisible];
	[newWindow release];
	
	//setup the map view controller
	MapViewController *aMapViewController = [[MapViewController alloc] init];
	[self setMapViewController:aMapViewController];
	[aMapViewController release];
	
    //toolbar bg
    UIImage *toolbarImage = [UIImage imageNamed:@"toolbarBackground.png"];
    
	//setup the main navigation controller with a map view controller as the root controller	
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];
    [navController.navigationBar setBackgroundImage:toolbarImage forBarMetrics:UIBarMetricsDefault];
	[navController.navigationBar setTintColor:[UIColor colorWithRed:47.0f/255.0f green:47.0f/255.0f blue:41.0f/255.0f alpha:1.0f]];
	[self setNavigationController:navController];
	[navController release];
	
	//add the nav controller view to the window
    self.window.rootViewController=navController;
	
	//download static config items
	[self performSelectorInBackground:@selector(downloadConfig) withObject:nil];
	
	//set the Flickr API Key
	[[FlickrAPIManager instance] setApiKey:[[Utilities instance].keysDict objectForKey:@"FlickrAPIKey"]];
	
	//setup facebook
	Facebook* theFacebook = [[Facebook alloc] initWithAppId:[[Utilities instance].keysDict objectForKey:@"FacebookAppID"] andDelegate:self];
	[self setFacebook:theFacebook];
	[theFacebook release];
    
    if (![Utilities instance].hasLoadedBefore) {
        _introVC = [[IntroViewController alloc] initWithNibName:@"IntroViewController" bundle:nil];
        [_introVC.view setFrame:CGRectMake(0.0f, 20.0f, self.navigationController.view.frame.size.width, self.navigationController.view.frame.size.height - 20.0f)];
        [_introVC.view setAutoresizingMask:UIViewAutoresizingFlexibleHeight];
        [_introVC.view setAlpha:0.0f];
        [self.navigationController.view addSubview:_introVC.view];
        
        [_introVC.closeButton addTarget:self action:@selector(closeIntro) forControlEvents:UIControlEventTouchUpInside];
        [_introVC.doneButton addTarget:self action:@selector(closeIntro) forControlEvents:UIControlEventTouchUpInside];
        
        [UIView animateWithDuration:0.3f delay:0.4f options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_introVC.view setAlpha:1.0f];
        } completion:^(BOOL finished) {
            [[Utilities instance] setHasLoadedBefore:YES];
        }];
        
    }
    self.locationMgr = [[CLLocationManager alloc] init];
    self.locationMgr.delegate = self;
    self.locationMgr.desiredAccuracy = kCLLocationAccuracyBest; // 100 m
    
    if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        [self.locationMgr requestAlwaysAuthorization];
    }
    
    [self.locationMgr startUpdatingLocation];
    return YES;
}
// For Map Current Location
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([CLLocationManager locationServicesEnabled])
    {
        NSLog(@"Location Services Enabled");
        
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App Permission Denied"
                                                            message:@"To re-enable, please go to Settings and turn on Location Service for this app."delegate:nil
                                                  cancelButtonTitle:@"OK"otherButtonTitles:nil];
            [alert show];
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (!self.lastLocation)
    {
        self.lastLocation = newLocation;
    }
}

- (void) closeIntro
{
    [UIView animateWithDuration:0.4f animations:^{
        [_introVC.view setAlpha:0.0f];
    } completion:^(BOOL finished) {
        [_introVC.view removeFromSuperview];
    }];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	//used for facebook single sign on
    return [self.facebook handleOpenURL:url]; 
}

- (void)downloadConfig
{
	//probably performing this in the background so create an autorelease pool
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	//todo: possibly lock the interface or display a message while this is happening
	[[AAAPIManager instance] downloadConfigWithTarget:nil callback:nil];
	
	//release pool
	[pool release];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
	/*
	 Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	 Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	 */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	/*
	 Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
	 If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	 */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
	/*
	 Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	 */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	/*
	 Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	 */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
	// Synchronize defaults
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	// Saves changes in the application's managed object context before the application terminates.
	[self saveContext];
}

- (void)dealloc
{
	[_window release];
	[__managedObjectContext release];
	[__managedObjectModel release];
	[__persistentStoreCoordinator release];
	[self setFacebook:nil];
    [super dealloc];
}

- (void)awakeFromNib
{
    /*
     Typically you should set up the Core Data stack here, usually by passing the managed object context to the first view controller.
     self.<#View controller#>.managedObjectContext = self.managedObjectContext;
    */
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}

/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:@"ArtAround" ofType:@"momd"];
    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }

	NSURL *storeURL = [NSURL fileURLWithPath:[(NSString *)[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"ArtAround.sqlite"]];
    
    NSLog(@"Core Data store path = \"%@\"", [storeURL path]);
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         */
        //[[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];

        /*
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter: 
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return __persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

#pragma mark - FBSessionDelegate

- (void)fbDidLogin
{
	//save the access token so the user will not have to authenticate every time
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
	
	//post a notification so other parts of the app know the login was successful
	[[NSNotificationCenter defaultCenter] postNotificationName:@"fbDidLogin" object:nil];
}

- (void)fbDidNotLogin:(BOOL)cancelled
{
	//if login failed and was not canclled, clear the access token and show an alert
	if (!cancelled) {
		
		//clear out the saved access token
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:nil forKey:@"FBAccessTokenKey"];
		[prefs setObject:nil forKey:@"FBExpirationDateKey"];
		[prefs synchronize];
		
		//show alert
		UIAlertView *facebookError = [[UIAlertView alloc] initWithTitle:@"Facebook Error" message:@"There was a problem sharing on Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[facebookError show];
		[facebookError release];

	}
}

@end
