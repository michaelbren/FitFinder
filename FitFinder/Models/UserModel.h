//
//  UserModel.h
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject{
    NSString *workoutPreference;
    NSString *fullName;
    NSString *gym;
}
@property (nonatomic, retain) NSString *workoutPreference;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) NSString *gym;

+ (id)sharedManager;

@end

