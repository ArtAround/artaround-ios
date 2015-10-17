//
//  Art.h
//  ArtAround
//
//  Created by Samosys on 25/08/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Comment, Event, Neighborhood, Photo, Tag;

@interface Art : NSManagedObject

@property (nonatomic, retain) NSString * artDescription;
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSNumber * commissioned;
@property (nonatomic, retain) NSString * commissionedBy;
@property (nonatomic, retain) NSString * commissionedByLink;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDecimalNumber * distance;
@property (nonatomic, retain) NSNumber * favorite;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * ward;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Neighborhood *neighborhood;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSSet *tags;
@end

@interface Art (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

- (void)addTagsObject:(Tag *)value;
- (void)removeTagsObject:(Tag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (NSString*)categoriesString;
- (NSString*)tagString;

@end
