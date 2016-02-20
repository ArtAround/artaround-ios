//
//  Art.m
//  ArtAround
//
//  Created by samosys on 20/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import "Art.h"
#import "Artist.h"
#import "Category.h"
#import "Comment.h"
#import "Event.h"
#import "Neighborhood.h"
#import "Photo.h"
#import "Tag.h"
@implementation Art

// Insert code here to add functionality to your managed object subclass
@dynamic artDescription;
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
@dynamic artists;

- (NSString*)categoriesString
{
    NSString *catString = @"";
    NSArray *catArray = [self.categories allObjects];
    
    NSMutableArray *catTitlesArray = [[NSMutableArray alloc] initWithCapacity:catArray.count];
    
    for (Category *thisCat in catArray) {
        [catTitlesArray addObject:thisCat.title];
    }
    
    if (catTitlesArray.count > 0)
        catString = [catTitlesArray componentsJoinedByString:@","];
    
    return catString;
}
- (NSString*)Singlecategories{
    NSString *catString = @"";
    NSArray *catArray = [self.categories allObjects];
    
    NSMutableArray *catTitlesArray = [[NSMutableArray alloc] initWithCapacity:catArray.count];
    int i = 0;
    for (Category *thisCat in catArray) {
        
        if (i<2) {
            [catTitlesArray addObject:thisCat.title];
        }
        else
        {
            break;
        }
        i++;
        
    }
    if (catTitlesArray.count > 0)
        catString = [catTitlesArray componentsJoinedByString:@","];
    
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
        tagString = [tagTitlesArray componentsJoinedByString:@","];
    
    return tagString;
}
- (NSString*)Singletag{
    NSString *tagString = @"";
    NSArray *tagArray = [self.tags allObjects];
    
    NSMutableArray *tagTitlesArray = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
    
    int i = 0;
    for (Tag *thistag in tagArray) {
        
        if (i<2) {
            [tagTitlesArray addObject:thistag.title];
        }
        else
        {
            break;
        }
        i++;
        
    }
    
    if (tagTitlesArray.count > 0)
        tagString = [tagTitlesArray componentsJoinedByString:@","];
    
    return tagString;
}
- (NSString*)ArtistString
{
    NSString *tagString = @"";
    NSArray *tagArray = [self.artists allObjects];
    
    NSMutableArray *tagTitlesArray = [[NSMutableArray alloc] initWithCapacity:tagArray.count];
    
    for (Tag *thistag in tagArray) {
        [tagTitlesArray addObject:thistag.title];
    }
    
    if (tagTitlesArray.count > 0)
        tagString = [tagTitlesArray componentsJoinedByString:@","];
    
    return tagString;
}


@end
