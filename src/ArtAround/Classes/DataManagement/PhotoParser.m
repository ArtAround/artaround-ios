//
//  PhotoParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "PhotoParser.h"

@implementation PhotoParser

+ (NSSet *)setForFlickrIDs:(NSArray *)flickrIDs inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *photos = [NSMutableSet set];
	for (NSNumber *flickrID in flickrIDs) {
		
		//get the photo for the given flickrID
		//add the photo to the set
		Photo *photo = [PhotoParser photoForFlickrID:flickrID inContext:context];
		[photos addObject:photo];
		
	}
	return photos;
}

+ (Photo *)photoForFlickrID:(NSNumber *)flickrID inContext:(NSManagedObjectContext *)context
{	
	//every once in a while a string is passed
	if ([flickrID isKindOfClass:[NSString class]]) {
		flickrID = [NSNumber numberWithLongLong:[flickrID longLongValue]];
	}
	
	//create a new photo if one doesn't exist yet
	Photo *photo = [ItemParser existingEntity:@"Photo" inContext:context uniqueKey:@"flickrID" uniqueValue:flickrID];
	if (!photo) {
		photo = (Photo *)[NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
		photo.flickrID = [AAAPIManager clean:flickrID];
	}
	return photo;
}

@end
