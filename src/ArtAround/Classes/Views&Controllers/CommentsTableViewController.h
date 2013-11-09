//
//  CommentsTableViewController.h
//  ArtAround
//
//  Created by Brian Singer on 7/16/13.
//  Copyright (c) 2013 ArtAround. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsTableViewController : UITableViewController
{
    NSDateFormatter *_dateFormatter;
}
@property (nonatomic, strong) NSArray *comments;

- (id)initWithStyle:(UITableViewStyle)style comments:(NSArray*)theComments;

@end
