//
//  CateTagViewController.m
//  ArtAround
//
//  Created by samosys on 18/02/16.
//  Copyright © 2016 ArtAround. All rights reserved.
//

#import "CateTagViewController.h"
#import "Art.h"
#import "Category.h"
#import "MapViewController.h"
@interface CateTagViewController ()<UITableViewDataSource,UITableViewDelegate>
{
 
}

@end

@implementation CateTagViewController
@synthesize searchItems=_searchItems;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *array =  [_category componentsSeparatedByString: @","];
    _searchItems = [[NSMutableArray alloc]initWithArray:array];
    // Do any additional setup after loading the view.
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _searchItems.count;
 }
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:simpleTableIdentifier ];
    }
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text=[_searchItems objectAtIndex:indexPath.row];
    //cell.backgroundColor = [UIColor colorWithRed:218.0/255.0 green:218.0/255.0 blue:218.0/255.0 alpha:1.0];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MapViewController *map = [[MapViewController alloc]init];
    map.catString= [_searchItems objectAtIndex:indexPath.row];
    map.Type= _type;
    [self.navigationController pushViewController:map animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
