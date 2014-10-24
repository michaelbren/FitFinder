//
//  ViewController.m
//  FitFinder
//
//  Created by Michael Brennan on 10/15/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "MainViewController.h"
#import <Parse/Parse.h>
#import "User.h"
#import "SignInUpViewController.h"
#import "MatchViewController.h"

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property UIViewController *signInUpViewController;
@property User *user;
@property UIButton *profileImage;

@property UILabel *fullName;
@property UILabel *email;
@property UILabel *workout;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    PFUser *currentUser = [PFUser currentUser];
    
    if (currentUser) {
        NSLog(@"There's a current user!");
        
        self.user = [[User alloc] initWithUser:currentUser];
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    PFUser *currentUser = [PFUser currentUser];
    if (!currentUser) {
        self.signInUpViewController = [[SignInUpViewController alloc] init];
        [self presentViewController:self.signInUpViewController animated:NO completion:nil];
    } else {
        self.user = [[User alloc] initWithUser:currentUser];
        
        NSLog(@"Jesus, finally we get here");
        // do stuff with the user
        CGPoint center = self.mainView.center;
        
        self.profileImage = [UIButton buttonWithType:UIButtonTypeCustom];
        self.profileImage.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height/2);
        if (self.user.avatar) {
            [self.profileImage setImage:self.user.avatar forState:UIControlStateNormal];
        } else {
            [self.profileImage setImage:[UIImage imageNamed:@"icon_419.png"] forState:UIControlStateNormal];
        }
        [self.profileImage addTarget:self action:@selector(tappedImagePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:self.profileImage];
        
        //UILabel *fullName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _fullName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _fullName.textAlignment = NSTextAlignmentCenter;
        _fullName.center = CGPointMake(center.x, center.y + 75);
        _fullName.text = self.user.fullName;
        [self.mainView addSubview:_fullName];
        
        //UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _email = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _email.textAlignment = NSTextAlignmentCenter;
        _email.center = CGPointMake(center.x, center.y + 125);
        _email.text = self.user.parseUser.email;
        [self.mainView addSubview:_email];
        
        //UILabel *workout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _workout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        _workout.textAlignment = NSTextAlignmentCenter;
        _workout.center = CGPointMake(center.x, center.y + 175);
        _workout.text = self.user.workoutPreference;
        [self.mainView addSubview:_workout];
        
        UIButton *logoutButton = [UIButton buttonWithType:UIButtonTypeSystem];
        logoutButton.frame = CGRectMake(center.x - 125, center.y + 200, 100, 40);
        [logoutButton setTitle:@"Logout" forState:UIControlStateNormal];
        [logoutButton addTarget:self action:@selector(logOutButton) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:logoutButton];
        
        UIButton *findMatchesButton = [UIButton buttonWithType:UIButtonTypeSystem];
        findMatchesButton.frame = CGRectMake(center.x + 25, center.y + 200, 100, 40);
        [findMatchesButton setTitle:@"Matches ->" forState:UIControlStateNormal];
        [findMatchesButton addTarget:self action:@selector(tappedMatchButton) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:findMatchesButton];
    }
}

- (void)logOutButton {
    // Hides the label so when you login again it doesn't show up
    self.fullName.hidden = YES;
    self.email.hidden = YES;
    self.workout.hidden = YES;
    
    [PFUser logOut];
    self.signInUpViewController = [[SignInUpViewController alloc] init];
    [self presentViewController:self.signInUpViewController animated:NO completion:nil];
}

- (void)tappedImagePicker {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:NO completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.user.avatar = [info objectForKey:UIImagePickerControllerOriginalImage];
    [self.profileImage setImage:self.user.avatar forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker removeFromParentViewController];
}

- (void)tappedMatchButton {
    MatchViewController *matchViewController = [[MatchViewController alloc] initWithUser:self.user];
    [self presentViewController:matchViewController animated:NO completion:nil];
}

@end
