//
//  CCBReportedViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 11/18/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBReportedViewController.h"

@interface CCBReportedViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UILabel *sickPredict;

@end

@implementation CCBReportedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)refreshSick {
//    PFUser *currentUser = [PFUser currentUser];
//    BOOL sick = [[currentUser objectForKey:@"CurrentlySick"] boolValue];
//    NSLog(@"CurrentlySick: %hhd", sick);
//    if (sick) {
//        _sickField.text = @"SICK";
//        _sickField.backgroundColor = [UIColor redColor];
//        _sickField.font = [UIFont systemFontOfSize:16];
//    } else {
//        _sickField.text = @"HEALTHY";
//        _sickField.backgroundColor = [UIColor colorWithRed:0/255.0f green:200/255.0f blue:18/255.0f alpha:1.0f];;
//        _sickField.font = [UIFont systemFontOfSize:12];
//    }
//}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UITabBar appearance] setTintColor:[UIColor redColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor darkGrayColor]];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser refresh];
    NSString *schooltemp = currentUser[@"School"];
    NSString *school = [schooltemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Current user school: %@", school);
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

    //get sickPredict
    if ([[CCBUserInfo sharedInstance] sickBool]) {
        
        NSMutableArray *symptoms = [[CCBUserInfo sharedInstance] currentSymptoms];
        NSLog(@"APPEARREEEDDDD %lu", (unsigned long)symptoms.count);
        if ([symptoms containsObject:@"Fever"] || [symptoms containsObject:@"Chills"]) {
            _sickPredict.text = @"You may have the flu.";
            NSLog(@"flu");
        }
        else if (symptoms.count >= 2) {
            NSLog(@"cold");
            _sickPredict.text = @"You may have a cold.";
        }
        else {
            NSLog(@"nosick");
            _sickPredict.text = @"";
        }
        
    }
    
	// Do any additional setup after loading the view.
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    //[query whereKey:@"Name" equalTo:school];
    [query whereKey:@"Name" equalTo:school];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully accessed school.");
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"Risk: %@", [object objectForKey:@"Risk"]);
                double risk =[[object objectForKey:@"Risk"] doubleValue];
                _riskIndicator.progress = risk/10;
                _riskString.text = [NSString stringWithFormat:@"UPenn Risk: %d", (int) risk];
                //_riskString.text = [NSString stringWithFormat:@"UPenn Health Score: %d", (int) (10-risk)];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}

- (IBAction)clickBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self.rootViewController getUserInfoValues];
    //[self.navigationController.topViewController updateView];
}



- (void) viewDidAppear {
    NSLog(@"DIDAPPEAR!");
    
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
