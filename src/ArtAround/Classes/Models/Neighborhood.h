//
//  Neighborhood.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Neighborhood : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *arts;
@end

@interface Neighborhood (CoreDataGeneratedAccessors)

- (void)addArtsObject:(Art *)value;
- (void)removeArtsObject:(Art *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
