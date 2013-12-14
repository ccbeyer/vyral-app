//
//  CCBAnnotation.h
//  vyral_Proto
//
//  Created by Chris Beyer on 12/12/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CCBAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
