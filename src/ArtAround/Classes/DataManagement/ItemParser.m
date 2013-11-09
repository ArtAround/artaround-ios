//
//  ItemParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//  Copyright 2011 ArtAround. All rights reserved.
//

#import "ItemParser.h"

static NSDateFormatter *_dateFormatter = nil;

@implementation ItemParser

- (id)init
{
    if (self = [super init]) {
		
		//observe NSManagedObjectContextDidSaveNotification
		[[NSNotificationCenter defaultCenter] addObserver:[AAAPIManager instance] selector:@selector(itemParserContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:[self managedObjectContext]];
		
	}
    return self;
}

+ (NSDateFormatter *)dateFormatter
{
	//setup the date formatter if it doesn't exist yet
	if (!_dateFormatter) {
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	}
	return _dateFormatter;
}

- (void)dealloc
{	
	//stop listening for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:[AAAPIManager instance] name:NSManagedObjectContextDidSaveNotification object:[self managedObjectContext]];

}

#pragma mark - Properties

- (AAManagedObjectContext *)managedObjectContext
{	
	//return the managed object context if it already exists for this parser
	//a separate managed object context is needed for each thread because it is not thread safe
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
	
	//setup the managed object context
	_managedObjectContext = [[AAManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:[AAAPIManager persistentStoreCoordinator]];
	[_managedObjectContext setUndoManager:nil]; // speeds up performance
	[_managedObjectContext setMergePolicy:NSOverwriteMergePolicy];
	
    return _managedObjectContext;
}

#pragma mark - Class Methods

+ (id)existingEntity:(NSString *)entityName inContext:(NSManagedObjectContext *)context uniqueKey:(NSString *)uniqueKey uniqueValue:(id)uniqueValue
{
	//initialize a request
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
	[request setEntity:entityDescription];
	[request setIncludesSubentities:NO];
	[request setFetchLimit:1];
	
	//set the predicate
	[request setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", uniqueKey, uniqueValue]];
	
	id entity = nil;
	@try {
		//get the returned object if there is one
		NSError *err;
		NSArray *results = [context executeFetchRequest:request error:&err];
		entity = (results && [results count] > 0) ? [results objectAtIndex:0] : nil;
	}
	@catch (NSException * e) {
		return nil;
	}
	@finally {
		request = nil;
	}
	
	//return the item
	return entity;
}

@end
