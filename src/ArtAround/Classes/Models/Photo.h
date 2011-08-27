//
//  Photo.h
//  ArtAround
//
//  Created by Brandon Jones on 8/26/11.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * flickrID;
@property (nonatomic, retain) Art *art;

@end
