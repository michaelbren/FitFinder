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

@interface MainViewController ()

@property (strong, nonatomic) IBOutlet UIView *mainView;
@property UIViewController *signInUpViewController;
@property User *user;
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
        
        UIButton *profileImage = [UIButton buttonWithType:UIButtonTypeCustom];
        profileImage.frame = CGRectMake(0, 0, self.mainView.frame.size.width, self.mainView.frame.size.height/2);
        if (self.user.avatar) {
            [profileImage setImage:self.user.avatar forState:UIControlStateNormal];
        } else {
            [profileImage setImage:[UIImage imageNamed:@"icon_419.png"] forState:UIControlStateNormal];
        }
        [profileImage addTarget:self action:@selector(tappedImagePicker) forControlEvents:UIControlEventTouchUpInside];
        [self.mainView addSubview:profileImage];

        UILabel *fullName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        fullName.textAlignment = NSTextAlignmentCenter;
        fullName.center = CGPointMake(center.x, center.y + 75);
        fullName.text = self.user.fullName;
        [self.mainView addSubview:fullName];
        
        UILabel *email = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        email.textAlignment = NSTextAlignmentCenter;
        email.center = CGPointMake(center.x, center.y + 125);
        email.text = self.user.parseUser.email;
        [self.mainView addSubview:email];
        
        UILabel *workout = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        workout.textAlignment = NSTextAlignmentCenter;
        workout.center = CGPointMake(center.x, center.y + 175);
        workout.text = self.user.workoutPreference;
        [self.mainView addSubview:workout];
        
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker removeFromParentViewController];
}

- (void)tappedMatchButton {
    
    PFQuery *query = [PFUser query];
    [query whereKey:@"workoutPreference" equalTo:self.user.workoutPreference]; // get all users with same workout pref as current
    NSArray *potentials = [query findObjects];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage: ((PFUser *)potentials.firstObject)[@"avatar"]];
    [self.mainView addSubview:imageView];
}

@end
