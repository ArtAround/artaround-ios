//
//  Category.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject {
@private
}
@property (nonatomic, strong) NSString * title;
@property (nonatomic, strong) NSSet *arts;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addArtsObject:(NSManagedObject *)value;
- (void)removeArtsObject:(NSManagedObject *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
