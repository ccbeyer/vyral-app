//
//  CCBUserInfo.m
//  vyral_Proto
//
//  Created by Chris Beyer on 12/6/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import "CCBUserInfo.h"

@implementation CCBUserInfo

+ (CCBUserInfo *)sharedInstance
{
    static CCBUserInfo *sharedInstance;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (NSString *)name
{
    // set some property for example
    return _name;
}


- (NSString *)school
{
    // set some property for example
    return _school;
}

- (BOOL)sickBool
{
    // set some property for example
    return _sickBool;
}

- (UIImage *)profilePicture
{
    // set some property for example
    return _profilePicture;
}

- (NSArray *)getCurrentSymptoms
{
    // set some property for example
    return _currentSymptoms;
}

- (NSDate *)lastReportDate
{
    return _lastReportDate;
}

- (NSInteger)schoolRisk
{
    // set some property for example
    return _schoolRisk;
}

@end
