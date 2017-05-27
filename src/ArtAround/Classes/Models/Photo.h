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
@property (nonatomic, strong) NSNumber * flickrID;
@property (nonatomic, strong) NSNumber * mediumHeight;
@property (nonatomic, strong) NSString * mediumSource;
@property (nonatomic, strong) NSString * mediumURL;
@property (nonatomic, strong) NSNumber * mediumWidth;
@property (nonatomic, strong) NSNumber * originalHeight;
@property (nonatomic, strong) NSString * originalSource;
@property (nonatomic, strong) NSString * originalURL;
@property (nonatomic, strong) NSNumber * originalWidth;
@property (nonatomic, strong) NSNumber * smallHeight;
@property (nonatomic, strong) NSString * smallSource;
@property (nonatomic, strong) NSString * smallURL;
@property (nonatomic, strong) NSNumber * smallWidth;
@property (nonatomic, strong) NSNumber * squareHeight;
@property (nonatomic, strong) NSString * squareSource;
@property (nonatomic, strong) NSString * squareURL;
@property (nonatomic, strong) NSNumber * squareWidth;
@property (nonatomic, strong) NSNumber * thumbnailHeight;
@property (nonatomic, strong) NSString * thumbnailSource;
@property (nonatomic, strong) NSString * thumbnailURL;
@property (nonatomic, strong) NSNumber * thumbnailWidth;
@property (nonatomic, strong) NSNumber * primary;
@property (nonatomic, strong) NSString * flickrName;
@property (nonatomic, strong) NSDate * dateAdded;
@property (nonatomic, strong) NSString * photoAttribution;
@property (nonatomic, strong) NSString * photoAttributionURL;
@property (nonatomic, strong) Art *art;

@end
