//
//  CCBReportedViewController.h
//  vyral_Proto
//
//  Created by Chris Beyer on 11/18/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface CCBReportedViewController : UIViewController <MKMapViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate>


@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) UIPageViewController *pageController;

- (void)setUserSick;



@end
