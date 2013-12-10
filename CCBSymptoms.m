//
//  CCBSymptoms.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/3/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBSymptoms.h"

@interface CCBSymptoms ()

@property (nonatomic, strong) NSArray *symptoms;
@property (nonatomic, strong) NSMutableArray *currentSymptoms;
@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;
@property (nonatomic, strong) IBOutlet UIButton *submit;

@end

@implementation CCBSymptoms

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _currentSymptoms = [[NSMutableArray alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Symptoms"];
    [query whereKey:@"Name" equalTo:@"Symptoms"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            
            for (PFObject *object in objects) {
                _symptoms = [object objectForKey:@"Symptoms"];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        

        [self.tableView reloadData];
    }];

    _nameField.text = [[CCBUserInfo sharedInstance] name];
    _schoolField.text = [[CCBUserInfo sharedInstance] school];
    BOOL sick = [[CCBUserInfo sharedInstance] sickBool];
    NSLog(@"CurrentlySick: %hhd", sick);
    if (sick) {
        _sickField.text = @"SICK";
        _sickField.backgroundColor = [UIColor redColor];
        _sickField.font = [UIFont systemFontOfSize:16];
    } else {
        _sickField.text = @"HEALTHY";
        _sickField.backgroundColor = [UIColor colorWithRed:0/255.0f green:200/255.0f blue:18/255.0f alpha:1.0f];;
        _sickField.font = [UIFont systemFontOfSize:12];
    }
    _imageView.image = [[CCBUserInfo sharedInstance] profilePicture];

    

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
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [_symptoms count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    
    // Configure the cell...
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundView.backgroundColor = [UIColor darkGrayColor];
    UILabel *label = (id)[cell viewWithTag:5];
    NSString *temp = [_symptoms objectAtIndex:indexPath.row];
    NSLog(@"%@",temp);
    label.text = temp;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    UISwitch *onOff = (id)[cell viewWithTag:3];
    UILabel *label = (id)[cell viewWithTag:5];
    if (onOff.isOn) {
        //deselect row
        onOff.on = FALSE;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.backgroundColor = [UIColor grayColor];
        [_currentSymptoms removeObject:label.text];
    }
    else {
        //select row
        onOff.on = TRUE;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
        cell.backgroundColor = [UIColor lightGrayColor];
        [_currentSymptoms addObject:label.text];
    }
    

}

- (IBAction)submit:(id)sender {
    [[CCBUserInfo sharedInstance] setCurrentSymptoms:_currentSymptoms];
    PFUser *currentUser = [PFUser currentUser];
    
    [currentUser setObject:_currentSymptoms forKey:@"currentSymptoms"];
    [currentUser saveInBackground];
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
