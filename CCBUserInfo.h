//
//  CCBUserInfo.h
//  vyral_Proto
//
//  Created by Chris Beyer on 12/6/13.
//  Copyright (c) 2013 Chris Beyer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBUserInfo : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *school;
@property (nonatomic, strong) UIImage *profilePicture;
@property (nonatomic) BOOL sickBool;
@property (nonatomic, strong) NSMutableArray *currentSymptoms;
@property (nonatomic, strong) NSDate *lastReportDate;


+ (CCBUserInfo *)sharedInstance;

@end
