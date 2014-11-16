//
//  UserModel.h
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef enum WorkoutType : NSInteger{
    Weightlifting, Running, Biking
} Workout;

@interface User : NSObject

-(instancetype)initWithUser:(PFUser *)user;
-(instancetype)initWithEmail:(NSString *)email andWithPassWord:(NSString *)password;

@property PFUser *parseUser;
@property NSString *fullName;
@property NSString *phoneNumber;
@property NSString *gym;
@property UIImage *avatar;

@property PFObject *matchData;

@property Workout workoutType;
@property NSString *workoutPreference;

@end
