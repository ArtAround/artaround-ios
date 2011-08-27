//
//  ItemParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"ASIHTTPRequest.h"
#import "AAAPIManager.h"
#import "AAManagedObjectContext.h"

@interface ItemParser : NSObject
{
	AAManagedObjectContext *_managedObjectContext;
}

@property (nonatomic, readonly) AAManagedObjectContext *managedObjectContext;

+ (id)existingEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)context uniqueKey:(NSString *)uniqueKey uniqueValue:(id)uniqueValue;
+ (NSDateFormatter *)dateFormatter;

@end
