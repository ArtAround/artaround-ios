//
//  Tag.h
//  ArtAround
//
//  Created by Samosys on 25/08/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Tag : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *arts;
@end

@interface Tag (CoreDataGeneratedAccessors)

- (void)addArtsObject:(NSManagedObject *)value;
- (void)removeArtsObject:(NSManagedObject *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
