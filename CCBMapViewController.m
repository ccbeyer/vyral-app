//
//  CCBMapViewController.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/11/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBMapViewController.h" 
#define MAX_SEARCH_DISTANCE_KM 2.0

@interface CCBMapViewController ()

@property (nonatomic, strong) NSMutableArray *allPosts;
@property (nonatomic, copy) NSString *className;

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
	// Do any additional setup after loading the view.
}

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation
                  withNearbyDistance:(CLLocationAccuracy)nearbyDistance
{
    PFQuery *wallPostQuery = [PFQuery queryWithClassName:@"SickLocation"];
    
    // If no objects are loaded in memory, we look to the cache first to fill the table
    // and then subsequently do a query against the network.
    if ([self.allPosts count] == 0)
    {
        wallPostQuery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    // Create a PFGeoPoint using the current location (to use in our query)
    PFGeoPoint *userLocation =
    [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude
                           longitude:currentLocation.coordinate.longitude];
    
    NSDate *now = [NSDate date];
    NSDate *sevenDaysAgo = [now dateByAddingTimeInterval:-7*24*60*60];
    
    // Create a PFQuery asking for all wall posts _km of the user
    [wallPostQuery whereKey:@"Location"
               nearGeoPoint:userLocation
           withinKilometers:MAX_SEARCH_DISTANCE_KM];
    [wallPostQuery whereKey:@"Date" greaterThanOrEqualTo:sevenDaysAgo];
    
    // Include the associated date in the returned data
    //[wallPostQuery includeKey:@"Date"];
    //Run the query in background with completion block
    [wallPostQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error) // The query failed
         {
             NSLog(@"Error in geo query!");
         }
         else // The query is successful
         {
             for (PFObject *object in objects)
             {
                 NSDictionary *point = @{@"Date": [object objectForKey:@"Date"],
                                          @"Location": [object objectForKey:@"Location"]};
                 [_allPosts addObject:point];
             }
             //[mapView addAnnotations:newPosts];
             
         }
     }];

}






- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
