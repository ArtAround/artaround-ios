//
//  Art.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright (c) 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Comment, Neighborhood, Photo, Event;

@interface Art : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSString * artDescription;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * ward;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSNumber * commissioned;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Neighborhood *neighborhood;
@property (nonatomic, retain) NSSet *photos;
@property (nonatomic, retain) NSDecimalNumber *distance;

//new v2 props
@property (nonatomic, retain) NSNumber * favorite;
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

- (NSString*)categoriesString;

@end
