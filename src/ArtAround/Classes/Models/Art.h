//
//  Art.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright (c) 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Category, Comment, Neighborhood, Photo;

@interface Art : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * artist;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSDecimalNumber * latitude;
@property (nonatomic, retain) NSString * locationDescription;
@property (nonatomic, retain) NSDecimalNumber * longitude;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * ward;
@property (nonatomic, retain) NSNumber * year;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) NSSet *comments;
@property (nonatomic, retain) Neighborhood *neighborhood;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Art (CoreDataGeneratedAccessors)

- (void)addCommentsObject:(Comment *)value;
- (void)removeCommentsObject:(Comment *)value;
- (void)addComments:(NSSet *)values;
- (void)removeComments:(NSSet *)values;

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end
