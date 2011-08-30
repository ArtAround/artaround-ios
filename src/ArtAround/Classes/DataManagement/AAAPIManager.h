//
//  AAAPIManager.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AAAPIManager : NSObject

//instance methods
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback;
- (void)downloadConfigWithTarget:(id)target callback:(SEL)callback;
- (NSArray *)categories;
- (NSArray *)neighborhoods;
- (NSArray *)titles;
- (NSArray *)artists;

//class methods
+ (AAAPIManager *)instance;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (id)clean:(id)object;

@end
