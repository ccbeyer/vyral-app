//
//  CCBTipsPageViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/16/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBTipsPageViewController.h"

@interface CCBTipsPageViewController ()

@property (nonatomic, strong) NSMutableArray *currentTips;

@end

@implementation CCBTipsPageViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    self.view.backgroundColor = [UIColor darkGrayColor];

    return self;
}

-(UITableView *)makeTableView
{
//    CGFloat x = 0;
//    CGFloat y = 50;
//    CGFloat width = 320;
//    CGFloat height = 125;
    //CGRect tableFrame = CGRectMake(x, y, width, height);
    
    UITableView *tableView = [[UITableView alloc] init];
    
    tableView.rowHeight = 55;
    //tableView.sectionFooterHeight = 22;
    //tableView.sectionHeaderHeight = 22;
    tableView.scrollEnabled = YES;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.userInteractionEnabled = YES;
    tableView.bounces = YES;
    tableView.backgroundColor = [UIColor darkGrayColor];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
    return tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView = [self makeTableView];
    NSLog(@"TABLEVIEW created");
    _currentTips = [[NSMutableArray alloc] init];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Tips"];
    [query whereKey:@"Symptom" containedIn:[CCBUserInfo sharedInstance].currentSymptoms];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            NSLog(@"Tips success: %d", [objects count]);
            for (PFObject *object in objects) {
                NSLog(@"Tip: %@", [object objectForKey:@"Tip"]);
                [_currentTips addObject:[object objectForKey:@"Tip"]];
                NSLog(@"Tip: %@", [_currentTips objectAtIndex:0]);
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        NSLog(@"currenttips success: %d", [_currentTips count]);
        [self.tableView reloadData];
    }];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [_currentTips count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"cellforrowatindex %ld", (long)indexPath.row);
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    // Configure the cell...
    //cell.textLabel.text = [NSString stringWithFormat:[yourItemsArray objectAtIndex:indexPath.row]];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [_currentTips objectAtIndex:indexPath.row]];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.numberOfLines = 2;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.textLabel.font = [ UIFont fontWithName: @"HelveticaNeue" size: 12.0 ];
    cell.backgroundColor = [UIColor darkGrayColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
