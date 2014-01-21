//
//  CCBLoginViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 11/12/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBLoginViewController.h"

@interface CCBLoginViewController ()

@end

@implementation CCBLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)loginButtonTouchHandler:(id)sender  {
    // The permissions requested from the user
    NSArray *permissionsArray = @[ @"user_about_me", @"user_relationships", @"user_birthday", @"user_location"];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //[_activityIndicator stopAnimating]; // Hide loading indicator
        
        if (!user) {
            if (!error) {
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else {
                NSLog(@"Uh oh. An error occurred: %@", error);
            }
        } else if (user.isNew) {
            NSLog(@"User with facebook signed up and logged in!");
            [self performSegueWithIdentifier:@"LoginToProfile" sender:self];
        } else {
            NSLog(@"User with facebook logged in!");
            [self performSegueWithIdentifier:@"LoginToProfile" sender:self];
        }
    }];
}

- (IBAction)dismissModal:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
