//
//  Comment.h
//  ArtAround
//
//  Created by Brandon Jones on 8/25/11.
//  Copyright 2011 ArtAround. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Comment : NSManagedObject {
@private
}
@property (nonatomic, strong) NSNumber * approved;
@property (nonatomic, strong) NSDate * createdAt;
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * commentID;
@property (nonatomic, strong) NSString * text;
@property (nonatomic, strong) NSString * url;
@property (nonatomic, strong) Art *art;

@end
