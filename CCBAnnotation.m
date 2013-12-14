//
//  CCBAnnotation.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/12/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBAnnotation.h"

@implementation CCBAnnotation
@synthesize coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    coordinate = coord;
    return self;
}

@end
