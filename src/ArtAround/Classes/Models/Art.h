//
//  Art.h
//  ArtAround
//
//  Created by Brian Singer on 7/9/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Comment, Event, Neighborhood, Photo;

@interface Art : NSManagedObject

@property (nonatomic, strong) NSString * artDescription;
@property (nonatomic, strong) NSString * artist;
@property (nonatomic, strong) NSString * commissionedBy;
@property (nonatomic, strong) NSNumber * commissioned;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSDecimalNumber * distance;
@property (nonatomic, strong) NSNumber * favorite;
@property (nonatomic, strong) NSDecimalNumber * latitude;
@property (nonatomic, strong) NSString * locationDescription;
@property (nonatomic, strong) NSDecimalNumber * longitude;
@property (nonatomic, strong) NSNumber * rank;
@property (nonatomic, strong) NSString * slug;
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSNumber * ward;
@property (nonatomic, strong) NSNumber * year;
@property (nonatomic, strong) NSString * commissionedByLink;
@property (nonatomic, strong) NSSet *categories;
@property (nonatomic, strong) NSSet *comments;
@property (nonatomic, strong) Event *event;
@property (nonatomic, strong) Neighborhood *neighborhood;
@property (nonatomic, strong) NSSet *photos;
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
