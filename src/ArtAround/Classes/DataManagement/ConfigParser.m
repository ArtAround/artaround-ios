//
//  ConfigParser.m
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import "ConfigParser.h"
#import "AAAPIManager.h"
#import "NeighborhoodParser.h"
#import	"CategoryParser.h"

@implementation ConfigParser

- (void)parseCategoryRequest:(ASIHTTPRequest *)categoryRequest neighborhoodRequest:(ASIHTTPRequest *)neighborhoodRequest userInfo:(NSDictionary *)userInfo
{	
	//deserialize the json responses
	NSArray *neighborhoods = [NeighborhoodParser arrayForNeighborhoodRequest:neighborhoodRequest];
	NSArray *categories = [CategoryParser arrayForCategoryRequest:categoryRequest];
	
	//lock the context
	[self.managedObjectContext lock];
	
	//add/update everything
	//todo: check and see if any neighborhoods were removed from the list
	//todo: check and see if any categories were removed from the list
	[NeighborhoodParser setForTitles:neighborhoods inContext:self.managedObjectContext];
	[CategoryParser setForTitles:categories inContext:self.managedObjectContext];
	
	//pass the userInfo along to the managedObjectContext
	[[self managedObjectContext] setUserInfo:userInfo];

	//save everything
	@try {
		NSError *error = nil;
		if (![[self managedObjectContext] save:&error]) {
			DebugLog(@"Error saving to the database: %@, %@", error, [error userInfo]);
		}
	}
	@catch (NSException * e) {
		DebugLog(@"Could not save art");
	}
	
	//unlock the context
	[self.managedObjectContext unlock];
}

- (void)dealloc {
    [super dealloc];
}

@end
