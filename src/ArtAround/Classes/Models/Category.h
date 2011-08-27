//
//  Category.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Category : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *arts;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addArtsObject:(NSManagedObject *)value;
- (void)removeArtsObject:(NSManagedObject *)value;
- (void)addArts:(NSSet *)values;
- (void)removeArts:(NSSet *)values;

@end
