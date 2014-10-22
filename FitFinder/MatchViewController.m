//
//  MatchViewController.m
//  FitFinder
//
//  Created by Michael Brennan on 10/21/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "MatchViewController.h"

@interface MatchViewController ()
@property NSArray *potentials;
@property UIImageView *matchView;
@property User *user;
@property UILabel *workout;
@property UILabel *fullName;
@end

@implementation MatchViewController

- (instancetype) initWithUser:(User *)user {
    if (self = [super init]) {
        self.user = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    PFQuery *query = [PFUser query];
    [query whereKey:@"workoutPreference" equalTo:self.user.workoutPreference]; // get all users with same workout pref as current
    self.potentials = [query findObjects];
    
    self.user = [[User alloc] initWithUser:(PFUser *)self.potentials.firstObject];
    
    self.matchView = [[UIImageView alloc] initWithImage: [UIImage imageWithData:[((PFUser *)self.potentials.firstObject)[@"avatar"] getData]]];
    self.matchView.frame = self.view.frame;
    
    CGPoint center = self.view.center;
    
    self.fullName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.fullName.textColor = [UIColor whiteColor];
    self.fullName.textAlignment = NSTextAlignmentCenter;
    self.fullName.center = CGPointMake(center.x, center.y + 75);
    self.fullName.text = self.user.fullName;
    [self.matchView addSubview:self.fullName];
    
    self.workout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.workout.textColor = [UIColor whiteColor];
    self.workout.textAlignment = NSTextAlignmentCenter;
    self.workout.center = CGPointMake(center.x, center.y + 175);
    self.workout.text = self.user.workoutPreference;
    [self.matchView addSubview:self.workout];
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped)];
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:leftSwipe];
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped)];
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:rightSwipe];
    
    [self.view addSubview:self.matchView];
}

- (void)swiped {
    self.potentials = [self.potentials subarrayWithRange:NSMakeRange(1, self.potentials.count - 1)];
    self.matchView.image = [UIImage imageWithData:[((PFUser *)self.potentials.firstObject)[@"avatar"] getData]];
    self.user = [[User alloc] initWithUser:(PFUser *)self.potentials.firstObject];
    self.fullName.text = self.user.fullName;
    self.workout.text = self.user.workoutPreference;
}


@end
