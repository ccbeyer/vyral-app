//
//  CCBHomeViewController.m
//  Sicklii_Proto
//
//  Created by Chris Beyer on 10/5/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBHomeViewController.h"


@interface CCBHomeViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *school;
@property (nonatomic) BOOL sickB;
@property (nonatomic, strong) UIImage *profilePic;
@property (nonatomic, strong) CLLocationManager *locationManager;


@end


@implementation CCBHomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (IBAction)logout:(id)sender {
//    [PFUser logOut];
//    PFUser *currentUser = [PFUser currentUser];
//}



- (void)viewDidLoad
{

    
    [super viewDidLoad];
    [[self locationManager] startUpdatingLocation];
	// Do any additional setup after loading the view.
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        // do stuff with the user
    
    //Hide Nav Bar
    [self.navigationController setNavigationBarHidden:YES];
    
    //Nav Bar Setup
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-35, 50, 700, 44)];
//    label.backgroundColor = [UIColor clearColor];
//    label.textColor = [UIColor whiteColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    label.text = @"vyral";
//    [label setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:30]];
//    // Do some stuff
//    [self.navigationItem setTitleView:label];
//    
//    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:.25 alpha:1.0];
    
    PFQuery *query= [PFUser query];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    //PFObject *user = [query getFirstObject];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error){
        
        //NAME
        _name = [user objectForKey:@"Name"];
//        _nameField.text = _name;
//        [[CCBUserInfo sharedInstance] setName:_name];
//        NSLog(@"CCBUserInfo: %@", [[CCBUserInfo sharedInstance] name]);
        
        //SCHOOL
        _school = [user objectForKey:@"School"];
//        _schoolField.text = _school;
//        [[CCBUserInfo sharedInstance] setSchool:_school];
        
        //SICK
        _sickB = [[user objectForKey:@"CurrentlySick"] boolValue];
//        [[CCBUserInfo sharedInstance] setSickBool:&_sick];
//        NSLog(@"CurrentlySick: %hhd", _sick);
//        if (_sick) {
//            _sickField.text = @"SICK";
//            _sickField.backgroundColor = [UIColor redColor];
//            _sickField.font = [UIFont systemFontOfSize:16];
//        } else {
//            _sickField.text = @"HEALTHY";
//            _sickField.backgroundColor = [UIColor colorWithRed:0/255.0f green:200/255.0f blue:18/255.0f alpha:1.0f];;
//            _sickField.font = [UIFont systemFontOfSize:12];
//        }
        
        //PROFILE PICTURE
        NSString *ImageURL = [user objectForKey:@"pictureURL"];
        NSLog(@"URL: %@", ImageURL);
        //NSString *ImageURL = @"https://graph.facebook.com/639529688/picture?type=large&return_ssl_resources=1";
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
        _profilePic = [UIImage imageWithData:imageData];
//        _imageView.image = _profilePic;
//        [[CCBUserInfo sharedInstance] setProfilePicture:_profilePic];
        [self updateUserInfoValues];
        [self updateView];
        
        }];
    
    
    _nameField.text = [[PFUser currentUser]valueForKey:@"Name"];
    _schoolField.text = [[PFUser currentUser]valueForKey:@"School"];

    } else {
        [self performSegueWithIdentifier:@"HomeToLogin" sender:self];
    }
    
    

}

- (void) updateView {
    _nameField.text = _name;
    _schoolField.text = _school;
    if (_sickB) {
        _sickField.text = @"SICK";
        _sickField.backgroundColor = [UIColor redColor];
        _sickField.font = [UIFont systemFontOfSize:16];
    } else {
        _sickField.text = @"HEALTHY";
        _sickField.backgroundColor = [UIColor colorWithRed:0/255.0f green:200/255.0f blue:18/255.0f alpha:1.0f];;
        _sickField.font = [UIFont systemFontOfSize:12];
    }
    _imageView.image = _profilePic;

}

- (void) getUserInfoValues {
    _name = [[CCBUserInfo sharedInstance] name];
    _school = [[CCBUserInfo sharedInstance] school];
    _sickB = [[CCBUserInfo sharedInstance] sickBool];
    _profilePic = [[CCBUserInfo sharedInstance] profilePicture];
}

- (void) updateUserInfoValues {
    [[CCBUserInfo sharedInstance] setName:_name];
    [[CCBUserInfo sharedInstance] setSchool:_school];
    [[CCBUserInfo sharedInstance] setSickBool:_sickB];
    [[CCBUserInfo sharedInstance] setProfilePicture:_profilePic];

}

- (void) viewDidAppear:(BOOL)animated
{

    if ([PFUser currentUser] && // Check if a user is cached
        [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) // Check if user is linked to Facebook
    {
        NSLog(@"LOGGEDIN");
        // Push the next view controller without animation

        
    }
    else {
        [self performSegueWithIdentifier:@"HomeToLogin" sender:self];
    }
    [self getUserInfoValues];
    [self updateView];
    
}

- (IBAction)setSick:(id)sender {
    
    //set user to Sick
    [[CCBUserInfo sharedInstance] setSickBool:YES];
    
    CLLocation *location = _locationManager.location;
    CLLocationCoordinate2D coordinate = [location coordinate];
    PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:coordinate.latitude
                                                  longitude:coordinate.longitude];
    
    PFUser *currentUser = [PFUser currentUser];
    
    NSDate *today = [NSDate date];
    
    //set last date report to today
    [[CCBUserInfo sharedInstance] setLastReportDate:today];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", date);
    
    BOOL sickbool = YES;
    NSNumber *sick = [NSNumber numberWithBool:sickbool];
    [self performSegueWithIdentifier:@"HomeToSymptoms" sender:self];
    
    NSDictionary *report = @{@"Date": date,
                             @"Sick": sick,
                             @"Location": geoPoint};
    
    [currentUser setObject:@YES forKey:@"CurrentlySick"];
    [currentUser addUniqueObject:report forKey:@"Date_SickReport"];
    [currentUser saveInBackground];
    
    
    PFQuery *sickLocationQuery = [PFQuery queryWithClassName:@"SickLocation"];
    
    NSDate *now = [NSDate date];
    NSDate *oneDayAgo = [now dateByAddingTimeInterval:-1*6*60*60];
    
    [sickLocationQuery whereKey:@"username" equalTo:[currentUser username]];
    [sickLocationQuery whereKey:@"createdAt" greaterThanOrEqualTo:now];
    //[sickLocationQuery whereKey:@"createdAt" greaterThanOrEqualTo:oneDayAgo];
    [sickLocationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) // The query failed
         {
             NSLog(@"Error in geo query!");
         }
         else // The query is successful
         {
             NSLog(@"REACHED: %lu", (unsigned long)[objects count]);
             if ([objects count] == 0) {
                 PFObject *sickLocation = [PFObject objectWithClassName:@"SickLocation"];
                 sickLocation[@"Date"] = today;
                 NSLog(@"LOCATION: %@", geoPoint);
                 sickLocation[@"Location"] = geoPoint;
                 sickLocation[@"username"] = [currentUser username];
                 [sickLocation saveInBackground];
             }
             
             
         }
         
         
     }];

    
    
    
    NSString *username = [currentUser objectForKey:@"username"];
    NSLog(@"username: %@", username);
    NSString *schooltemp = currentUser[@"School"];
    NSString *school = [schooltemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query whereKey:@"Name" equalTo:school];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects

            for (PFObject *object in objects) {
                NSLog(@"Home added user to school: %@", username);

                [object addUniqueObject:username forKey:@"usersSick"];
                [object saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        
    }];
    

}

- (IBAction)clearSick:(id)sender {
    [[CCBUserInfo sharedInstance] setSickBool:NO];
    [self performSegueWithIdentifier:@"HomeToReported" sender:self];
    PFUser *currentUser = [PFUser currentUser];
    
    NSDate *today = [NSDate date];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSString *date = [dateFormat stringFromDate:today];
    NSLog(@"date: %@", date);
    
    BOOL sickbool = NO;
    NSNumber *sick = [NSNumber numberWithBool:sickbool];
    

    
    NSDictionary *report = @{@"Date": date,
                             @"Sick": sick};
    
    [currentUser addUniqueObject:report forKey:@"Date_SickReport"];
    
    [currentUser setObject:@NO forKey:@"CurrentlySick"];
    [currentUser saveInBackground];

    
    NSString *username = [currentUser objectForKey:@"username"];
    NSLog(@"username: %@", username);
    NSString *schooltemp = currentUser[@"School"];
    NSString *school = [schooltemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    [query whereKey:@"Name" equalTo:school];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            // Do something with the found objects
            
            for (PFObject *object in objects) {
                [object removeObject:username forKey:@"usersSick"];
                [object saveInBackground];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([segue.identifier isEqualToString:@"HomeToReported"]) {
        [segue.destinationViewController setHappiness:100];
    } else if ([segue.identifier isEqualToString:@"Sad"]) {
        [segue.destinationViewController setHappiness:0];
    }
}

- (CLLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager setDelegate:self];
    [_locationManager setPurpose:@"Your current location is used to provide accurate data on your risk of getting sick."];
    
    return _locationManager;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
