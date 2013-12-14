//
//  CCBMapViewController.h
//  vyral_Proto
//
//  Created by Chris Beyer on 12/11/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface CCBMapViewController : UIViewController <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
