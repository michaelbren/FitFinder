//
//  UserModel.m
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "User.h"


@implementation User

@synthesize fullName = _fullName;
@synthesize phoneNumber = _phoneNumber;
@synthesize gym = _gym;
@synthesize workoutPreference = _workoutPreference;
@synthesize workoutType = _workoutType;
@synthesize avatar = _avatar;


-(instancetype)initWithUser:(PFUser *)user {
    if (self = [super init]) {
        self.parseUser = user;
        self.fullName = self.parseUser[@"fullName"];
        self.workoutPreference = self.parseUser[@"workoutPreference"];
//        self.gym = self.parseUser[@"gym"];
        NSData *image = [self.parseUser[@"avatar"] getData];
        if (image) {
            self.avatar = [UIImage imageWithData:image];
            NSLog(@"Image");
        } else {
            NSLog(@"No Image");
        }
    }
    return self;
}

-(instancetype)initWithEmail:(NSString *)email andWithPassWord:(NSString *)password {
    
    if (self = [super init]) {
        self.parseUser = [PFUser user];
        
        self.parseUser.username = email;
        self.parseUser.password = password;
        self.parseUser.email = email;
        
    }
    
    return self;
}


-(void)setFullName:(NSString *)fullName{
    _fullName = fullName;
    NSLog(@"setFullName %@\n", fullName);
    self.parseUser[@"fullName"] = fullName;
}

-(NSString *)fullName{
    return _fullName;
}

-(void)setGym:(NSString *)gym{
    _gym = gym;
    NSLog(@"setGym %@\n", gym);
    self.parseUser[@"gym"] = gym;
}

-(NSString *)gym{
    return _gym;
}

// Getters/Setters for workout preference
-(void)setWorkoutPreference:(NSString *)workoutPreference {
    _workoutPreference = workoutPreference;
    NSLog(@"setWorkoutPreference %@\n", workoutPreference);
    self.parseUser[@"workoutPreference"] = self.workoutPreference;
}

-(NSString *)workoutPreference {
    return _workoutPreference;
}

-(void)setWorkoutType:(Workout)workoutType {
    _workoutType = workoutType;
    NSLog(@"setWorkoutType %d", workoutType);
    NSArray *workoutPreferences = @[@"Weightlifting", @"Running"];
    self.workoutPreference = [workoutPreferences objectAtIndex:_workoutType];
}

-(Workout)workoutType {
    return _workoutType;
}

-(void)setPhoneNumber:(NSString *)phoneNumber {
    _phoneNumber = phoneNumber;
    NSLog(@"setPhoneNumber %@\n", phoneNumber);
    self.parseUser[@"phoneNumber"] = phoneNumber;
}

-(NSString *)phoneNumber {
    return _phoneNumber;
}

-(void)setAvatar:(UIImage *)avatar {
    _avatar = avatar;
    NSData *imageData = UIImageJPEGRepresentation(avatar, 0.4);
    PFFile *file = [PFFile fileWithName:@"avatar.jpg" data:imageData];
    self.parseUser[@"avatar"] = file;
    [self.parseUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"SUCCESS saving avatar");
        } else {
            NSLog(@"Failure to save avatar");
        }
    }];
}

-(UIImage *)avatar {
    NSData *image = [self.parseUser[@"avatar"] getData];
    _avatar = [UIImage imageWithData:image];
    return _avatar;
}

@end
