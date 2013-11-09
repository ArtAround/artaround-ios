//
//  Event.h
//  ArtAround
//
//  Created by Brian Singer on 3/11/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define kEventSlugKey @"slug"
#define kEventNameKey @"name"
#define kEventStartsKey @"starts_at"
#define kEventEndsKey @"ends_at"
#define kEventWebsiteKey @"website"
#define kEventIconURLKey @"icon_thumbnail_url"
#define kEventIconURLSmallKey @"icon_small_url"
#define kEventDescriptionKey @"description"

@class Art;

@interface Event : NSManagedObject

@property (nonatomic, strong) NSDate * ends;
@property (nonatomic, strong) NSDate * starts;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * iconURL;
@property (nonatomic, strong) NSString * iconURLSmall;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * eventDescription;
@property (nonatomic, strong) NSString * slug;
@property (nonatomic, strong) NSSet *arts;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addArtsObject:(Art *)value;
- (void)removeArtsObject:(Art *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
