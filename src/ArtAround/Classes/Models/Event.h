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

@property (nonatomic, retain) NSDate * ends;
@property (nonatomic, retain) NSDate * starts;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * iconURL;
@property (nonatomic, retain) NSString * iconURLSmall;
@property (nonatomic, retain) NSString * website;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSSet *arts;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addArtsObject:(Art *)value;
- (void)removeArtsObject:(Art *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
