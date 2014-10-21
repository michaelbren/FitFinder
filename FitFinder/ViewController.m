//
//  ViewController.m
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "ViewController.h"
#import <Parse/Parse.h>
#import "UserModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.weightliftBtn addTarget:self action:@selector(wlbtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self.runningBtn addTarget:self action:@selector(rbtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UserModel *user = [[UserModel alloc]init];
}

-(void)wlbtnClicked
{
    NSLog(@"weightlifting");
    _user.workoutPreference = Weightlifting;
    
}

-(void)rbtnClicked
{
    NSLog(@"running");
    _user.workoutPreference = Running;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
