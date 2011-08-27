//
//  Comment.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Comment : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * approved;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) Art *art;

@end
