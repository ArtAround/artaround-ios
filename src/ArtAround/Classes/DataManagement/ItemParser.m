//
//  ItemParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import "ItemParser.h"
#import "AAAPIManager.h"

@implementation ItemParser

- (id)init
{
    if (self = [super init]) {
		
		//observe NSManagedObjectContextDidSaveNotification
		[[NSNotificationCenter defaultCenter] addObserver:[AAAPIManager instance] selector:@selector(itemParserContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:[self managedObjectContext]];
		
		//setup the date formatter
		_dateFormatter = [[NSDateFormatter alloc] init];
		[_dateFormatter setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
		[_dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
		
	}
    return self;
}

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

- (void)dealloc
{	
	//stop listening for notifications
	[[NSNotificationCenter defaultCenter] removeObserver:[AAAPIManager instance] name:NSManagedObjectContextDidSaveNotification object:[self managedObjectContext]];

	if (_managedObjectContext) {
		[_managedObjectContext release];
	}
    [super dealloc];
}
@end
