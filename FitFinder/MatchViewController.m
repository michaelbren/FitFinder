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
@property User *otherUser;
@property User *currentUser;
@property UILabel *workout;
@property UILabel *fullName;
@property UIButton *backButton;

@property UIButton *likeButton;
@property UIButton *dislikeButton;

@property UISwipeGestureRecognizer *rightSwipe;
@property UISwipeGestureRecognizer *leftSwipe;
@end

@implementation MatchViewController

- (instancetype) initWithCurrentUser:(User *)user {
    if (self = [super init]) {
        self.currentUser = user;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    PFQuery *query = [PFUser query];
    [query whereKey:@"objectId" notEqualTo:[self.currentUser.parseUser objectId]];
    [query whereKey:@"workoutPreference" equalTo:self.currentUser.workoutPreference]; // get all users with same workout pref as current
    self.potentials = [query findObjects];

    
    self.otherUser = [[User alloc] initWithUser:(PFUser *)self.potentials.firstObject];
    
    self.matchView = [[UIImageView alloc] initWithImage: [UIImage imageWithData:[((PFUser *)self.potentials.firstObject)[@"avatar"] getData]]];
    self.matchView.frame = self.view.frame;
    
    CGPoint center = self.view.center;
    
    self.fullName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.fullName.textColor = [UIColor whiteColor];
    self.fullName.textAlignment = NSTextAlignmentCenter;
    self.fullName.center = CGPointMake(center.x, center.y + 75);
    self.fullName.text = self.otherUser.fullName;
    [self.matchView addSubview:self.fullName];
    
    self.workout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    self.workout.textColor = [UIColor whiteColor];
    self.workout.textAlignment = NSTextAlignmentCenter;
    self.workout.center = CGPointMake(center.x, center.y + 175);
    self.workout.text = self.otherUser.workoutPreference;
    [self.matchView addSubview:self.workout];
    
    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.backButton.frame = CGRectMake(0, 0, 120, 60);
    [self.backButton setTitle:@"<- back" forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(backButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    self.dislikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.dislikeButton.frame = CGRectMake(0, CGRectGetHeight(self.view.frame) - 80, 80, 80);
    [self.dislikeButton setImage:[UIImage imageNamed:@"icon_45885.png"] forState:UIControlStateNormal];
    [self.dislikeButton addTarget:self action:@selector(swipedLeft) forControlEvents:UIControlEventTouchUpInside];
    
    self.likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.likeButton.frame = CGRectMake(CGRectGetWidth(self.view.frame) - 80, CGRectGetHeight(self.view.frame) - 80, 80, 80);
    [self.likeButton setImage:[UIImage imageNamed:@"icon_45888.png"] forState:UIControlStateNormal];
    [self.likeButton addTarget:self action:@selector(swipedRight) forControlEvents:UIControlEventTouchUpInside];
    
    self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedLeft)];
    self.leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:self.leftSwipe];
    
    self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedRight)];
    self.rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:self.rightSwipe];

    
    [self.view addSubview:self.matchView];
    
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.likeButton];
    [self.view addSubview:self.dislikeButton];
}

- (void)backButtonTapped {
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)swipedLeft { // Disliked
    PFUser *potential = self.potentials.firstObject;
    
    PFRelation *relation = [self.currentUser.parseUser relationForKey:@"Dislikes"];
    [relation addObject:potential];
    PFRelation *unRelation = [self.currentUser.parseUser relationForKey:@"Likes"];
    [unRelation removeObject:potential];
    [self.currentUser.parseUser saveInBackground];

    self.potentials = [self.potentials subarrayWithRange:NSMakeRange(1, self.potentials.count - 1)];
    if (self.potentials.count == 0) {
        self.matchView.image = [UIImage imageNamed:@"icon_2623.png"];
        self.matchView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        [self.backButton setTitle:@"" forState:UIControlStateNormal];
        self.backButton.frame = self.matchView.frame;
        self.fullName.text = @"Out of Matches!";
        self.workout.text = @"";
        
        [self.likeButton removeFromSuperview];
        [self.dislikeButton removeFromSuperview];
        [self.view removeGestureRecognizer:self.leftSwipe];
        [self.view removeGestureRecognizer:self.rightSwipe];
    } else {
        potential = self.potentials.firstObject;
        self.matchView.image = [UIImage imageWithData:[potential[@"avatar"] getData]];
        
        self.otherUser = [[User alloc] initWithUser:potential];
        self.fullName.text = self.otherUser.fullName;
        self.workout.text = self.otherUser.workoutPreference;
    }
}

- (void)swipedRight {
    PFUser *potential = self.potentials.firstObject;
    
    PFRelation *relation = [self.currentUser.parseUser relationForKey:@"Likes"];
    [relation addObject:potential];
    PFRelation *unRelation = [self.currentUser.parseUser relationForKey:@"Dislikes"];
    [unRelation removeObject:potential];
    [self.currentUser.parseUser saveInBackground];

    NSString *myId = [self.currentUser.parseUser objectId];
    
    PFRelation *potentialsRelation = [potential relationForKey:@"Likes"];
    
    PFQuery *query = [potentialsRelation query];
    [query whereKey:@"objectId" equalTo:myId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"OBJECTS!!! %d", objects.count);
            if (objects.count == 1) {
                    // Present message composer
                    MFMessageComposeViewController *messageViewController = [[MFMessageComposeViewController alloc] init];
                    messageViewController.recipients = @[potential[@"phoneNumber"]];
                    [self presentViewController:messageViewController animated:NO completion:nil];
            }
    }];

    self.potentials = [self.potentials subarrayWithRange:NSMakeRange(1, self.potentials.count - 1)];
    if (self.potentials.count == 0) {
        self.matchView.image = [UIImage imageNamed:@"icon_2623.png"];
        self.matchView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
        [self.backButton setTitle:@"" forState:UIControlStateNormal];
        self.backButton.frame = self.matchView.frame;
        self.fullName.text = @"Out of Matches!";
        self.workout.text = @"";
        
        [self.likeButton removeFromSuperview];
        [self.dislikeButton removeFromSuperview];
        [self.view removeGestureRecognizer:self.leftSwipe];
        [self.view removeGestureRecognizer:self.rightSwipe];
    } else {
        potential = self.potentials.firstObject;
        self.matchView.image = [UIImage imageWithData:[potential[@"avatar"] getData]];
        
        self.otherUser = [[User alloc] initWithUser:potential];
        self.fullName.text = self.otherUser.fullName;
        self.workout.text = self.otherUser.workoutPreference;
    }
}


@end
