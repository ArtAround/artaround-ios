//
//  Photo.h
//  ArtAround
//
//  Created by Brandon Jones on 8/28/11.
//  Copyright (c) 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Art;

@interface Photo : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * flickrID;
@property (nonatomic, retain) NSNumber * mediumHeight;
@property (nonatomic, retain) NSString * mediumSource;
@property (nonatomic, retain) NSString * mediumURL;
@property (nonatomic, retain) NSNumber * mediumWidth;
@property (nonatomic, retain) NSNumber * originalHeight;
@property (nonatomic, retain) NSString * originalSource;
@property (nonatomic, retain) NSString * originalURL;
@property (nonatomic, retain) NSNumber * originalWidth;
@property (nonatomic, retain) NSNumber * smallHeight;
@property (nonatomic, retain) NSString * smallSource;
@property (nonatomic, retain) NSString * smallURL;
@property (nonatomic, retain) NSNumber * smallWidth;
@property (nonatomic, retain) NSNumber * squareHeight;
@property (nonatomic, retain) NSString * squareSource;
@property (nonatomic, retain) NSString * squareURL;
@property (nonatomic, retain) NSNumber * squareWidth;
@property (nonatomic, retain) NSNumber * thumbnailHeight;
@property (nonatomic, retain) NSString * thumbnailSource;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) NSNumber * thumbnailWidth;
@property (nonatomic, retain) NSNumber * primary;
@property (nonatomic, retain) NSString * flickrName;
@property (nonatomic, retain) NSDate * dateAdded;
@property (nonatomic, retain) Art *art;

@end
