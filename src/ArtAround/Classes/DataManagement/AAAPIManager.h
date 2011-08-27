//
//  AAAPIManager.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import <Foundation/Foundation.h>

@interface AAAPIManager : NSObject
{
}

//instance methods
- (void)downloadArtWithTarget:(id)target callback:(SEL)callback;
- (void)downloadConfigWithTarget:(id)target callback:(SEL)callback;
- (NSArray *)categories;
- (NSArray *)neighborhoods;
- (NSArray *)titles;
- (NSArray *)artists;

//class methods
+ (AAAPIManager *)instance;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end
