//
//  Photo.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright (c) 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * flickrID;
@property (nonatomic, retain) NSString * square;
@property (nonatomic, retain) NSString * thumbnail;
@property (nonatomic, retain) NSString * small;
@property (nonatomic, retain) NSString * medium;
@property (nonatomic, retain) NSString * original;
@property (nonatomic, retain) Art *art;

@end
