//
//  TLYTableViewController.m
//  TLYShyNavBarDemo
//
//  Created by Bunny Lin on 2014/11/17.
//  Copyright (c) 2014年 Telly, Inc. All rights reserved.
//

#import "TLYTableViewController.h"

@interface TLYTableViewController ()

@end

@implementation TLYTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView registerClass:[UITableViewCell class]
           forCellReuseIdentifier:@"UITableViewCell"];
    
    /* Library code */
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44.f)];
    view.backgroundColor = [UIColor redColor];
    
    self.shyNavBarManager.scrollView = self.tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [NSString stringWithFormat:@"section: %d row: %d",indexPath.section, indexPath.row];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView * v = [[UITableViewHeaderFooterView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 25)];
    v.contentView.backgroundColor = [UIColor greenColor];
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 2, self.view.frame.size.width, 22)];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor clearColor];
    label.text = [NSString stringWithFormat:@"section: %d",section];
    [v addSubview:label];
    return v;
}



@end
