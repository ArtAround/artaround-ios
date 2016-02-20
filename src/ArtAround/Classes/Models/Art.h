//
//  Art.h
//  ArtAround
//
//  Created by samosys on 20/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Artist, Category, Comment, Event, Neighborhood, Photo;

NS_ASSUME_NONNULL_BEGIN

@interface Art : NSManagedObject

@property (nullable, nonatomic, retain) NSString *artDescription;
@property (nullable, nonatomic, retain) NSNumber *commissioned;
@property (nullable, nonatomic, retain) NSString *commissionedBy;
@property (nullable, nonatomic, retain) NSString *commissionedByLink;
@property (nullable, nonatomic, retain) NSDate *createdAt;
@property (nullable, nonatomic, retain) NSDecimalNumber *distance;
@property (nullable, nonatomic, retain) NSNumber *favorite;
@property (nullable, nonatomic, retain) NSDecimalNumber *latitude;
@property (nullable, nonatomic, retain) NSString *locationDescription;
@property (nullable, nonatomic, retain) NSDecimalNumber *longitude;
@property (nullable, nonatomic, retain) NSNumber *rank;
@property (nullable, nonatomic, retain) NSString *slug;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSNumber *ward;
@property (nullable, nonatomic, retain) NSString *website;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSSet<Category *> *categories;
@property (nullable, nonatomic, retain) NSSet<Comment *> *comments;
@property (nullable, nonatomic, retain) Event *event;
@property (nullable, nonatomic, retain) Neighborhood *neighborhood;
@property (nullable, nonatomic, retain) NSSet<Photo *> *photos;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *tags;
@property (nullable, nonatomic, retain) NSSet<Artist *> *artists;

// Insert code here to declare functionality of your managed object subclass

@end

@interface Art (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet<Category *> *)values;
- (void)removeCategories:(NSSet<Category *> *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet<Comment *> *)values;
- (void)removeComments:(NSSet<Comment *> *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet<Photo *> *)values;
- (void)removePhotos:(NSSet<Photo *> *)values;

- (void)addTagsObject:(NSManagedObject *)value;
- (void)removeTagsObject:(NSManagedObject *)value;
- (void)addTags:(NSSet<NSManagedObject *> *)values;
- (void)removeTags:(NSSet<NSManagedObject *> *)values;

- (void)addArtistsObject:(Artist *)value;
- (void)removeArtistsObject:(Artist *)value;
- (void)addArtists:(NSSet<Artist *> *)values;
- (void)removeArtists:(NSSet<Artist *> *)values;

- (NSString*)categoriesString;
- (NSString*)Singlecategories;
- (NSString*)tagString;
- (NSString*)Singletag;
-(NSString *)ArtistString;
@end

NS_ASSUME_NONNULL_END
