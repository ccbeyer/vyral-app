//
//  CCBMapViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/11/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBMapViewController.h" 
#import "CCBAnnotation.h"
#import "MBXMapKit.h"
#define MAX_SEARCH_DISTANCE_KM 2.0
#define MAP_ID "chrisbeyer.ghk86opp"

@interface CCBMapViewController ()

@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) CLLocationManager *locationManager;

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;

@end

@implementation CCBMapViewController

@synthesize className;


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
    _allPosts = [[NSMutableArray alloc] init];
    CLLocation *location = _locationManager.location;
    //CLLocationCoordinate2D coordinate = [location coordinate];
    //[self.view addSubview:[[MBXMapView alloc] initWithFrame:self.view.bounds mapID:@MAP_ID]];
    _mapView = [[MBXMapView alloc] initWithFrame:self.view.bounds mapID:@MAP_ID];
   // _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.showsUserLocation = YES;
    //_mapView.mapType = MKMapTypeSatellite;
    _mapView.delegate = self;
    //[_mapView setShowsPointsOfInterest:NO];
    

    
    [self.view addSubview:_mapView];
    [self queryForAllPostsNearLocation:location withNearbyDistance:self.locationManager.desiredAccuracy];
	// Do any additional setup after loading the view.
    
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
    [_locationManager setPurpose:@"Your current location is used to demonstrate PFGeoPoint and Geo Queries."];
    
    return _locationManager;
}

- (void)mapView:(MKMapView *)aMapView didUpdateUserLocation:(MKUserLocation *)aUserLocation {
    NSLog(@"USERFOUND");
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta = 0.005;
    span.longitudeDelta = 0.005;
    CLLocationCoordinate2D location;
    location.latitude = aUserLocation.coordinate.latitude;
    location.longitude = aUserLocation.coordinate.longitude;
    region.span = span;
    region.center = location;
    [aMapView setRegion:region animated:YES];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
