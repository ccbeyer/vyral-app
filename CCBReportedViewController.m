//
//  CCBReportedViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 11/18/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBReportedViewController.h"
#import "CCBMapViewController.h"
#import "CCBAnnotation.h"
#import "CCBRiskPageViewController.h"
#import "CCBTipsPageViewController.h"
#import "MBXMapKit.h"

#define MAX_SEARCH_DISTANCE_KM 2.0
#define MAP_ID "chrisbeyer.ghk86opp"

@interface CCBReportedViewController ()

@property (nonatomic, strong) IBOutlet UILabel *nameField;
@property (nonatomic, strong) IBOutlet UILabel *schoolField;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *sickField;
@property (nonatomic, strong) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UILabel *sickPredict;
@property (nonatomic, strong) IBOutlet UIProgressView *riskIndicator;
@property (nonatomic, strong) IBOutlet UILabel *riskString;
@property (nonatomic, strong) IBOutlet UIButton *Back;

@property (nonatomic) BOOL riskQueryFinished;
@property (strong, nonatomic) IBOutlet UIButton *schoolButton;
@property (strong, nonatomic) IBOutlet UIButton *threeDayButton;
@property (strong, nonatomic) IBOutlet UIButton *currentButton;



@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) MKUserLocation *currentUserLocation;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;

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
    _riskQueryFinished = NO;
    
#pragma INITIALIZE VIEW APPEARANCE
    //INITIALIZE VIEW
    PFUser *currentUser = [PFUser currentUser];
    [currentUser refresh];
    NSString *schooltemp = currentUser[@"School"];
    NSString *school = [schooltemp stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSLog(@"Current user school: %@", school);

    //_nameField.text = [[CCBUserInfo sharedInstance] name];
    //_schoolField.text = [[CCBUserInfo sharedInstance] school];
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

    //_imageView.image = [[CCBUserInfo sharedInstance] profilePicture];

    
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
    
#pragma QUERY FOR RISK
    //QUERY FOR RISK
    PFQuery *query = [PFQuery queryWithClassName:@"School"];
    //[query whereKey:@"Name" equalTo:school];
    [query whereKey:@"Name" equalTo:school];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            _riskQueryFinished = YES;
            // The find succeeded.
            NSLog(@"Successfully accessed school.");
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"Risk: %@", [object objectForKey:@"Risk"]);
                double risk =[[object objectForKey:@"Risk"] doubleValue];
                [[CCBUserInfo sharedInstance] setSchoolRisk:(NSInteger)risk];
                _riskIndicator.progress = risk/10;
                _riskString.text = [NSString stringWithFormat:@"UPenn Risk: %d", (int) risk];
                //_riskString.text = [NSString stringWithFormat:@"UPenn Health Score: %d", (int) (10-risk)];
            }
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
    
    
    
#pragma INITIALIZE MAP VIEW
    //INITIALIZE MAP VIEW
    _allPosts = [[NSMutableArray alloc] init];
    CLLocation *location = _locationManager.location;
    //CLLocationCoordinate2D coordinate = [location coordinate];
    //[self.view addSubview:[[MBXMapView alloc] initWithFrame:self.view.bounds mapID:@MAP_ID]];
    _mapView = [[MBXMapView alloc] initWithFrame:CGRectMake(0,80,320,365) mapID:@MAP_ID];
    // _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    //_mapView.mapType = MKMapTypeSatellite;
    _mapView.delegate = self;
    //[_mapView setShowsPointsOfInterest:NO];
    
    
    //[_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    [self.view addSubview:_mapView];
    [self queryForAllPostsNearLocation:location withNearbyDistance:self.locationManager.desiredAccuracy];
    
#pragma INITIALIZE PAGE VIEW
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    
    self.pageController.dataSource = self;
    float verticalPos = (self.view.frame.size.height - 125);
    [[self.pageController view] setFrame:CGRectMake(0,verticalPos,320,125)];
    [self.pageController view].backgroundColor = [UIColor darkGrayColor];
    
    UIViewController *initialViewController = [self viewControllerAtIndex:0];
    UIViewController *secondViewController = [self viewControllerAtIndex:1];
    
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];


}


- (UIViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    UIViewController *childViewController;
    NSLog(@"INDEX = %lu", (unsigned long)index);
    if (index == 0) {
        childViewController = [[CCBRiskPageViewController alloc] init];
        ((CCBRiskPageViewController *)childViewController).index = index;
        
        _riskIndicator = [[UIProgressView alloc] initWithFrame:CGRectMake(85,50,150,20)];
        _riskIndicator.progressTintColor = RISK_RED;
        _riskIndicator.trackTintColor = RISK_GREEN;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 2.0f);
        _riskIndicator.transform = transform;
        double risk =[[CCBUserInfo sharedInstance] schoolRisk];
        _riskIndicator.progress = risk/10;
        [childViewController.view addSubview:_riskIndicator];
        
        _riskString = [[UILabel alloc] initWithFrame:CGRectMake(85,70,150,20)];
        [_riskString setTextColor:[UIColor whiteColor]];
        _riskString.textAlignment = NSTextAlignmentCenter;
        if (_riskQueryFinished) {
            _riskString.text = [NSString stringWithFormat:@"UPenn Risk: %d", (int) risk];
        }
        [childViewController.view addSubview:_riskString];

    }
    else {
        childViewController = [[CCBTipsPageViewController alloc] init];
        ((CCBTipsPageViewController *)childViewController).index = index;
//        ((CCBTipsPageViewController *)childViewController).tableView.dataSource = self;

    }

    
    return childViewController;
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index;
    if ([NSStringFromClass([viewController class]) isEqualToString:@"CCBRiskPageViewController"]) {
        index = [(CCBRiskPageViewController *)viewController index];
    }
    else {
        index = [(CCBTipsPageViewController *)viewController index];
    }
    
    if (index == 0) {
        return [self viewControllerAtIndex:1];
    } else {
        return [self viewControllerAtIndex:0];
    }
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index;
    if ([NSStringFromClass([viewController class]) isEqualToString:@"CCBRiskPageViewController"]) {
        index = [(CCBRiskPageViewController *)viewController index];
    }
    else {
        index = [(CCBTipsPageViewController *)viewController index];
    }
    
    if (index == 0) {
        return [self viewControllerAtIndex:1];
    } else {
        return [self viewControllerAtIndex:0];
    }
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return 0;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}



- (IBAction)clickBack:(id)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
    //[self.rootViewController getUserInfoValues];
    //[self.navigationController.topViewController updateView];
}


- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation
                  withNearbyDistance:(CLLocationAccuracy)nearbyDistance
{
    PFQuery *wallPostQuery = [PFQuery queryWithClassName:@"SickLocation"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    //    if ([self.allPosts count] == 0)
    //    {
    //        wallPostQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    //    }
    
    // Create a PFGeoPoint using the current location (to use in our query)
    PFGeoPoint *userLocation =
    [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                           longitude:currentLocation.coordinate.longitude];
    
    NSDate *now = [NSDate date];
    NSDate *sevenDaysAgo = [now dateByAddingTimeInterval:-7*24*60*60];
    
    // Create a PFQuery asking for all wall posts _km of the user
    
    //[wallPostQuery whereKey:@"Location" nearGeoPoint:userLocation withinKilometers:MAX_SEARCH_DISTANCE_KM];
    //[wallPostQuery whereKey:@"Date" greaterThanOrEqualTo:sevenDaysAgo];
    
    // Include the associated date in the returned data
    //[wallPostQuery includeKey:@"createdAt"];
    //Run the query in background with completion block
    [wallPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         NSLog(@"SIZE = %lu", sizeof(objects));
         if (error) // The query failed
         {
             NSLog(@"Error in geo query!");
         }
         else // The query is successful
         {
             for (PFObject *object in objects)
             {
                 //NSDictionary *point = @{@"Date": [object objectForKey:@"Date"], @"Location": [object objectForKey:@"Location"]};
                 NSDictionary *point = @{@"Location": [object objectForKey:@"Location"]};
                 NSLog(@"point: %@", point);
                 [_allPosts addObject:point];
                 
                 //                 PFGeoPoint *post = [point objectForKey:@"Location"];
                 //                 NSLog(@"lat: %f  long: %f", post.latitude, post.longitude);
                 //                 CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(post.latitude, post.longitude);
                 //                 CCBAnnotation *annotation = [[CCBAnnotation alloc] initWithCoordinate:coordinate];
                 //                 [self.mapView addAnnotation:annotation];
             }
             NSLog(@"sizeof: %lu", sizeof(_allPosts));
             for (PFObject *post in _allPosts) {
                 NSLog(@"NEWANNOTATION");
                 PFGeoPoint *point = [post objectForKey:@"Location"];
                 NSLog(@"lat: %f  long: %f", point.latitude, point.longitude);
                 CLLocationCoordinate2D coords = CLLocationCoordinate2DMake(point.latitude, point.longitude);
                 CCBAnnotation *annotation = [[CCBAnnotation alloc] initWithCoordinate:coords];
                 [self.mapView addAnnotation:annotation];
             }
             [self centerMap];

             
         }
         
         
     }];
    
    
}

- (void)setUserSick {
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

- (CLLocationManager *)locationManager {
    if (_locationManager != nil) {
        return _locationManager;
    }
    
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    [_locationManager setDelegate:self];
    //[_locationManager setPurpose:@"Your current location is used to demonstrate PFGeoPoint and Geo Queries."];
    return _locationManager;
}


//- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
//    NSLog(@"UPDATED LOCATION");
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.02;
//    span.longitudeDelta = 0.02;
//    CLLocationCoordinate2D location;
//    CLLocation *currentLocation = [locations lastObject];
//    location.latitude = currentLocation.coordinate.latitude;
//    location.longitude = currentLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [_mapView setRegion:region animated:YES];
//}

- (void)centerMap {
    NSLog(@"USERFOUND");
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.02;
    span.longitudeDelta = 0.02;
    CLLocationCoordinate2D location;
    location.latitude = _currentUserLocation.coordinate.latitude;
    location.longitude = _currentUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [_mapView setRegion:region animated:YES];

}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    _currentUserLocation = aUserLocation;
//    NSLog(@"USERFOUND");
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.02;
//    span.longitudeDelta = 0.02;
//    CLLocationCoordinate2D location;
//    location.latitude = aUserLocation.coordinate.latitude;
//    location.longitude = aUserLocation.coordinate.longitude;
//    region.span = span;
//    region.center = location;
//    [aMapView setRegion:region animated:YES];
}


//custom annotation image
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
    {
        return nil;
    }
    else if ([annotation isKindOfClass:[CCBAnnotation class]])
    {
        static NSString * const identifier = @"MyCustomAnnotation";
        
        MKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        
        if (annotationView)
        {
            annotationView.annotation = annotation;
        }
        else
        {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:identifier];
        }
        
        // set your annotationView properties
        
        annotationView.image = [UIImage imageNamed:@"orangeDot.png"];
        annotationView.canShowCallout = NO;
        
        
        return annotationView;
    }
    
    return nil;
}

-(void)mapView:(MKMapView *)pMapView regionDidChangeAnimated:(BOOL)animated
{

    float scale = .008/(_mapView.region.span.latitudeDelta/2);
    if (scale > 1) {
        scale = 1;
    } else if (scale < .13 && scale > .09) {
        scale = 0.13;
    }
    NSLog(@"SCALE: %f", scale);
    
    //Scale the annotations
    for( CCBAnnotation *annotation in [[self mapView] annotations] ){
        
        if ([annotation isKindOfClass:[CCBAnnotation class]]) {
            UIImage *tempImage = [UIImage imageNamed:@"orangeDot.png"];
            CGImageRef imgRef = [tempImage CGImage];
            
            CGFloat width = CGImageGetWidth(imgRef);
            CGFloat height = CGImageGetHeight(imgRef);
            CGRect bounds = CGRectMake(0, 0, width, height);
            CGSize size = bounds.size;
            
            CGAffineTransform transform = CGAffineTransformMakeScale(scale, scale);
            
            UIGraphicsBeginImageContext(size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextConcatCTM(context, transform);
            CGContextDrawImage(context, bounds, imgRef);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            [[[self mapView] viewForAnnotation: annotation] setImage:image];
        
            
        }
    }
    
}

- (IBAction)buttonClick:(UIButton *)sender {
    _schoolButton.selected = NO;
    _threeDayButton.selected = NO;
    _currentButton.selected = NO;
    sender.selected = YES;
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
