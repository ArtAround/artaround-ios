//
//  CommentParser.m
//  ArtAround
//
//  Created by Brian Singer on 2/9/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "CommentParser.h"
#import "JSONKit.h"
#import "Art.h"

@implementation CommentParser



+ (NSSet *)setForArray:(NSArray *)commentsArray inContext:(NSManagedObjectContext *)context
{
	NSMutableSet *comments = [[NSMutableSet alloc] init];
    
	for (NSDictionary *comment in commentsArray) {
		
		//get the photo for the given flickrID
		//add the photo to the set
		Comment *thisComment = [CommentParser commentForDict:comment inContext:context];
		[comments addObject:thisComment];
		
	}
	return comments;
}

+ (Comment *)commentForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context
{
	//get or create a neighborhood with the given title
	Comment *comment = [ItemParser existingEntity:@"Comment" inContext:context uniqueKey:@"commentID" uniqueValue:[dict objectForKey:@"_id"]];
	if (!comment) {
		comment = (Comment *)[NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:context];
		comment.commentID = [AAAPIManager clean:[dict objectForKey:@"_id"]];       
	}
    
    comment.text = [AAAPIManager clean:[dict objectForKey:@"text"]];
    comment.url = [AAAPIManager clean:[dict objectForKey:@"url"]];
    comment.name = [AAAPIManager clean:[dict objectForKey:@"name"]];
    comment.email = [AAAPIManager clean:[dict objectForKey:@"email"]];        
    
    NSString *dateString = [[NSString alloc] initWithString:[[dict objectForKey:@"created_at"] substringToIndex:10]];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    comment.createdAt = [dateFormatter dateFromString:dateString];
    
    comment.approved = [AAAPIManager clean:[dict objectForKey:@"approved"]]; 
    
	return comment;
}



@end
