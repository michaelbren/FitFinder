//
//  UserModel.h
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

enum WorkoutType {
    Weightlifting, Running
};

@property enum WorkoutType workoutPreference;
@property NSString *fullName;
@property NSString *gym;

@end
