//
//  AAAPIManager.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h> 

//#define kArtAroundURL @"http://www.theartaround.us"
#define kArtAroundURL @"http://staging.theartaround.us"

@interface AAAPIManager : NSObject

//instance methods
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback;
- (void)downloadAllArtWithTarget:(id)target callback:(SEL)callback forceDownload:(BOOL)force;
- (void)downloadArtForSlug:(NSString*)slug target:(id)target callback:(SEL)callback;
- (void)downloadArtForSlug:(NSString*)slug target:(id)target callback:(SEL)callback forceDownload:(BOOL)force;
- (void)downloadConfigWithTarget:(id)target callback:(SEL)callback;
- (void)submitArt:(NSDictionary*)art withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback;
- (void)updateArt:(NSMutableDictionary*)art withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback;

- (void)uploadImage:(UIImage*)image forSlug:(NSString*)slug withFlickrHandle:(NSString*)flickrHandle withPhotoAttributionURL:(NSString*)url withTarget:(id)target callback:(SEL)callback failCallback:(SEL)failCallback;

- (void)uploadComment:(NSDictionary*)commentDictionary forSlug:(NSString*)slug target:(id)target callback:(SEL)callback failCallback:(SEL)failCallback;
- (void)submitFlagForSlug:(NSString*)slug withText:(NSString*)text target:(id)target callback:(SEL)callback failCallback:(SEL)failCallback;

- (NSArray *)categories;
- (NSArray *)neighborhoods;
- (NSArray *)titles;
- (NSArray *)artists;
- (NSArray *)events;

//class methods
+ (AAAPIManager *)instance;
+ (NSManagedObjectContext *)managedObjectContext;
+ (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
+ (id)clean:(id)object;

@end
