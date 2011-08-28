//
//  FlickrAPIManager.h
//  ArtAround
//
//  Created by Brandon Jones on 8/28/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrAPIManager : NSObject

@property (nonatomic, copy) NSString *apiKey;

+ (FlickrAPIManager *)instance;
+ (const NSString *)flickrIDKey;
- (void)downloadPhotoWithID:(NSNumber *)flickrID target:(id)target callback:(SEL)callback;

@end
