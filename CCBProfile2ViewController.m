//
//  CCBProfile2ViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/2/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBProfile2ViewController.h"

@interface CCBProfile2ViewController ()
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) IBOutlet UITextField *ageField;
@property (nonatomic, strong) IBOutlet UITextField *genderField;
@property (nonatomic, strong) IBOutlet UITextField *schoolField;
@property (nonatomic, strong) IBOutlet UIButton *cancelButton;

@end

@implementation CCBProfile2ViewController

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
    _nameField.text = [currentUser objectForKey:@"Name"];
    NSLog(@"NAME:::: %@", [currentUser objectForKey:@"Name"]);
    _ageField.text = [NSString stringWithFormat:@"%@", [currentUser objectForKey:@"Age"]];
    _genderField.text = [currentUser objectForKey:@"Gender"];
    _schoolField.text = [currentUser objectForKey:@"School"];
}

- (IBAction)dismissModalCancel:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismissModal:(id)sender {
    
    NSInteger age = [_ageField.text intValue];
    PFUser *currentUser = [PFUser currentUser];
    [currentUser setObject:[NSNumber numberWithInt:age] forKey:@"Age"];
    [currentUser setObject:_genderField.text forKey:@"Gender"];
    [currentUser setObject:_nameField.text forKey:@"Name"];
    [currentUser setObject:_schoolField.text forKey:@"School"];
    [currentUser saveInBackground];
    
    if (self.presentingViewController.presentingViewController == NULL) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
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
