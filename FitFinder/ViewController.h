//
//  ViewController.h
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *weightliftBtn;

@property (weak, nonatomic) IBOutlet UIButton *runningBtn;

@property UserModel *user;

@end

