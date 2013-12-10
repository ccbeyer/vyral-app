//
//  CCBHomeProfileViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/3/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBHomeProfileViewController.h"



@interface CCBHomeProfileViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;

@end

@implementation CCBHomeProfileViewController

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
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        
        
    } else {
        [self performSegueWithIdentifier:@"Login" sender:self];
    }
    
    PFQuery *query= [PFUser query];
    
    [query whereKey:@"username" equalTo:[[PFUser currentUser]username]];
    PFObject *user = [query getFirstObject];
    //[query getFirstObjectInBackgroundWithBlock:^(PFObject *user, NSError *error){}];
        
        _nameField.text = [user objectForKey:@"Name"];
        _schoolField.text = [user objectForKey:@"School"];
        BOOL sick = [[user objectForKey:@"CurrentlySick"] boolValue];
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
        
    
    
    
    NSString *ImageURL = [user objectForKey:@"pictureURL"];
    NSLog(@"URL: %@", ImageURL);
    //NSString *ImageURL = @"https://graph.facebook.com/639529688/picture?type=large&return_ssl_resources=1";
    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ImageURL]];
    _imageView.image = [UIImage imageWithData:imageData];
    

    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
