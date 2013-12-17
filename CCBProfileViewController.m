//
//  CCBProfileViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 11/13/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBProfileViewController.h"

@interface CCBProfileViewController ()
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *ageField;
@property (nonatomic, strong) IBOutlet UITextField *genderField;
@property (nonatomic, strong) IBOutlet UITextField *schoolField;
@property (nonatomic, strong) NSString *pictureURL;

@end

@implementation CCBProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    // Create request for user's Facebook data
    FBRequest *request = [FBRequest requestForMe];
    
    // Send request to Facebook
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            // result is a dictionary with the user's Facebook data
            NSDictionary *userData = (NSDictionary *)result;
            
            NSString *facebookID = userData[@"id"];
            NSString *name = userData[@"name"];
            //NSString *location = userData[@"location"][@"name"];
            NSString *gender = userData[@"gender"];
            NSString *birthday = userData[@"birthday"];
            //NSString *relationship = userData[@"relationship_status"];
            NSArray *education = userData[@"education"];
            
            NSString *currentEducation;
            NSInteger latestEducationYear = 0;
            for (id obj in education) {
                NSString *school = [[obj objectForKey:@"school"] objectForKey:@"name"];
                NSInteger year = [[[obj objectForKey:@"year"] objectForKey:@"name"] intValue];
                NSLog(@"%@ %ld",school, (long)year);
                currentEducation = school;
//                if (year > latestEducationYear) {
//                    latestEducationYear = year;
//                    currentEducation = school;
//                }
            }
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"MM/dd/yyyy"];
            NSDate *birthDate = [df dateFromString:birthday];
            
            NSDate *now = [NSDate date];
            NSDateComponents *ageComponents = [[NSCalendar currentCalendar]
                                               components:NSYearCalendarUnit
                                               fromDate:birthDate
                                               toDate:now
                                               options:0];
            NSInteger age = [ageComponents year];
        
            
            
           //_pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
            _pictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID];
            
            
            // Now add the data to the UI elements
            _nameField.text = name;
            _ageField.text = [NSString stringWithFormat:@"%d", age];
            _genderField.text = gender;
            _schoolField.text = currentEducation;
            
            //for (id obj in education)
            //    NSLog(@"obj: %@", obj);
            
        }
    }];
    
}

- (IBAction)dismissModal:(id)sender {
    
    NSInteger age = [_ageField.text intValue];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:[NSNumber numberWithInt:age] forKey:@"Age"];
    [currentUser setObject:_genderField.text forKey:@"Gender"];
    [currentUser setObject:_nameField.text forKey:@"Name"];
    [currentUser setObject:_schoolField.text forKey:@"School"];
    [currentUser setObject:_pictureURL forKey:@"pictureURL"];
    [currentUser saveInBackground];
    
    //[self.navigationController popToRootViewControllerAnimated:YES];
    
    if (self.presentingViewController.presentingViewController == NULL) {
        NSLog(@"NULL");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        NSLog(@"VC: %@", self.presentingViewController.presentingViewController);
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![[touch view] isKindOfClass:[UITextField class]]) {
        [self.view endEditing:YES];
    }
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
