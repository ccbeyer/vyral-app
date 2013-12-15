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
    _allPosts = [[NSMutableArray alloc] init];
    CLLocation *location = _locationManager.location;
    //CLLocationCoordinate2D coordinate = [location coordinate];
    //[self.view addSubview:[[MBXMapView alloc] initWithFrame:self.view.bounds mapID:@MAP_ID]];
    _mapView = [[MBXMapView alloc] initWithFrame:CGRectMake(0,125,320,420) mapID:@MAP_ID];
    // _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    //_mapView.mapType = MKMapTypeSatellite;
    _mapView.delegate = self;
    //[_mapView setShowsPointsOfInterest:NO];
    
    
    //[_mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
    [self.view addSubview:_mapView];
    [self queryForAllPostsNearLocation:location withNearbyDistance:self.locationManager.desiredAccuracy];

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



- (void) viewDidAppear {
    NSLog(@"DIDAPPEAR!");
    
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
