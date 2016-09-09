//
//  TLYTableViewController.m
//  TLYShyNavBarDemo
//
//  Created by Mazyad Alabduljaleel on 11/13/15.
//  Copyright © 2015 Telly, Inc. All rights reserved.
//

#import "TLYTableViewController.h"

@interface TLYTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) IBInspectable int numberOfSections;
@property (nonatomic, assign) IBInspectable int numberOfRowsPerSection;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@end

@implementation TLYTableViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
    view.backgroundColor = [UIColor redColor];
    
    /* Library code */
    self.shyNavBarManager.scrollView = self.tableView;
    /* Can then be remove by setting the ExtensionView to nil */
    [self.shyNavBarManager setExtensionView:view];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.numberOfRowsPerSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Section Header";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                                            forIndexPath:indexPath];
    
    cell.textLabel.text = @"Sample Data";
    
    return cell;
}

@end
