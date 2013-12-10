//
//  CCBTipsViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/3/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBTipsViewController.h"

@interface CCBTipsViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;
@property (nonatomic, strong) IBOutlet UIButton *backButton;

@end

@implementation CCBTipsViewController



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
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor darkGrayColor]];
	// Do any additional setup after loading the view.
//    PFUser *currentUser = [PFUser currentUser];
//    [currentUser refresh];
//    NSString *schooltemp = currentUser[@"School"];
//    NSString *school = [schooltemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
//    NSLog(@"Current user school: %@", school);
    //PFQuery *query1= [PFUser query];
    
    //[query1 whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    //PFObject *user = [query1 getFirstObject];
    //[query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error){}];
    
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
    
    
    
    
//    NSString *ImageURL = [user objectForKey:@"pictureURL"];
//    NSLog(@"URL: %@", ImageURL);
//    //NSString *ImageURL = @"https://graph.facebook.com/639529688/picture?type=large&return_ssl_resources=1";
//    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    _imageView.image = [[CCBUserInfo sharedInstance] profilePicture];
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];

}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
