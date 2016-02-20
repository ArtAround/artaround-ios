//
//  Artist.h
//  ArtAround
//
//  Created by samosys on 20/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

NS_ASSUME_NONNULL_BEGIN

@interface Artist : NSManagedObject
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSSet<Art *> *arts;
// Insert code here to declare functionality of your managed object subclass

@end


@interface Artist (CoreDataGeneratedAccessors)

- (void)addArtsObject:(Art *)value;
- (void)removeArtsObject:(Art *)value;
- (void)addArts:(NSSet<Art *> *)values;
- (void)removeArts:(NSSet<Art *> *)values;

@end

NS_ASSUME_NONNULL_END
