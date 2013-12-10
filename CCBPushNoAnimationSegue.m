//
//  CCBPushNoAnimationSegue.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/6/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBPushNoAnimationSegue.h"

@implementation CCBPushNoAnimationSegue

-(void) perform{
    [[[self sourceViewController] navigationController] pushViewController:[self   destinationViewController] animated:NO];
}

@end
