//
//  CommentParser.h
//  ArtAround
//
//  Created by Brian Singer on 2/9/12.
//  Copyright (c) 2012 ArtAround. All rights reserved.
//

#import "ItemParser.h"
#import "Comment.h"

@interface CommentParser : ItemParser

+ (NSSet *)setForArray:(NSArray *)commentsArray inContext:(NSManagedObjectContext *)context;
+ (Comment *)commentForDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;

@end
