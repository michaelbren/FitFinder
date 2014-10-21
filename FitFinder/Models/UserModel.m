//
//  UserModel.m
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "UserModel.h"


@implementation UserModel

@synthesize workoutPreference;
@synthesize fullName;
@synthesize gym;


+ (id)sharedManager {
    static UserModel *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}
@end
