//
//  ItemParser.h
//  ArtAround
//
//  Created by Brandon Jones on 8/27/11.
//
//

#import <Foundation/Foundation.h>
#import	"ASIHTTPRequest.h"
#import "AAManagedObjectContext.h"

@interface ItemParser : NSObject
{
	AAManagedObjectContext *_managedObjectContext;
	NSDateFormatter *_dateFormatter;
}

@property (nonatomic, readonly) AAManagedObjectContext *managedObjectContext;

@end
