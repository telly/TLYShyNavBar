//
//  TLYPopoverSegue.m
//  TLYShyNavBarDemo
//
//  Created by Evan Schoenberg on 8/23/16.
//  Copyright © 2016 Telly, Inc. All rights reserved.
//

#import "TLYPopoverSegue.h"


@implementation TLYPopoverSegue

- (void)perform
{
    UITableViewController *tvc = (UITableViewController *)self.sourceViewController;
    UIViewController *dest = self.destinationViewController;
    UITableViewCell *cell = [tvc.tableView cellForRowAtIndexPath:[tvc.tableView indexPathForSelectedRow]];
    
    UIPopoverController *pop = [[UIPopoverController alloc] initWithContentViewController:dest];
    CGSize size = CGSizeMake(640, 460);
    pop.popoverContentSize = size;
    
    
    [pop presentPopoverFromRect:cell.frame
                         inView:tvc.tableView
       permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                       animated:YES];
}
@end
