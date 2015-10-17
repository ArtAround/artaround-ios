//
//  Art.m
//  ArtAround
//
//  Created by Samosys on 25/08/15.
//  Copyright (c) 2015 ArtAround. All rights reserved.
//

#import "Art.h"
#import "Category.h"
#import "Comment.h"
#import "Event.h"
#import "Neighborhood.h"
#import "Photo.h"
#import "Tag.h"


@implementation Art

@dynamic artDescription;
@dynamic artist;
@dynamic commissioned;
@dynamic commissionedBy;
@dynamic commissionedByLink;
@dynamic createdAt;
@dynamic distance;
@dynamic favorite;
@dynamic latitude;
@dynamic locationDescription;
@dynamic longitude;
@dynamic rank;
@dynamic slug;
@dynamic title;
@dynamic ward;
@dynamic website;
@dynamic year;
@dynamic categories;
@dynamic comments;
@dynamic event;
@dynamic neighborhood;
@dynamic photos;
@dynamic tags;



- (NSString*)categoriesString
{
    NSString *catString = @"";
    NSArray *catArray = [self.categories allObjects];
    
    NSMutableArray *catTitlesArray = [[NSMutableArray alloc] initWithCapacity:catArray.count];
    
    for (Category *thisCat in catArray) {
        [catTitlesArray addObject:thisCat.title];
    }
    
    if (catTitlesArray.count > 0)
        catString = [catTitlesArray componentsJoinedByString:@", "];
    
    return catString;
}

- (NSString*)tagString
{
    NSString *tagString = @"";
    NSArray *tagArray = [self.tags allObjects];
    
    NSMutableArray *tagTitlesArray = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
    
    for (Tag *thistag in tagArray) {
        [tagTitlesArray addObject:thistag.title];
    }
    
    if (tagTitlesArray.count > 0)
        tagString = [tagTitlesArray componentsJoinedByString:@", "];
    
    return tagString;
}

@end
