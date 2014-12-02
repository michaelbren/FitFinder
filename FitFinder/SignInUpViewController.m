//
//  SignInUpViewController.m
//  FitFinder
//
//  Created by Michael Brennan on 10/21/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "SignInUpViewController.h"

@interface SignInUpViewController ()

@property UITextField *emailField;
@property UITextField *phoneNumberField;
@property UITextField *passwordField;
@property UITextField *fullName;

@property UIButton *loginButton;
@property UIButton *signupButton;
@property UIButton *actualSignUpButton;

@property UIButton *weightLiftingButton;
@property UIButton *runningButton;
@property Workout workoutType;
@end

@implementation SignInUpViewController

-(instancetype)init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    CGPoint center = self.view.center;
    
    self.emailField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 80, 300, 40)];
    self.emailField.placeholder = @"Email";
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    self.emailField.clearButtonMode = YES;
    self.emailField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [self.view addSubview:self.emailField];
    
    self.passwordField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y, 300, 40)];
    self.passwordField.placeholder = @"Password";
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.clearButtonMode = YES;
    self.passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordField.secureTextEntry = YES;
    [self.view addSubview:self.passwordField];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.frame = CGRectMake(center.x - 100, center.y + 140, 200, 40);
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(tappedLoginButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.signupButton.frame = CGRectMake(center.x - 100, center.y + 180, 200, 40);
    [self.signupButton setTitle:@"or sign up here" forState:UIControlStateNormal];
    [self.signupButton addTarget:self action:@selector(tappedSignupButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signupButton];
    
    // Delegate setting
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.fullName.delegate = self;
}

-(void)tappedLoginButton:(id)sender {
    // login
    [PFUser logInWithUsernameInBackground:self.emailField.text password:self.passwordField.text
                                    block:^(PFUser *user, NSError *error) {
                                        if (user) {
                                            // Do stuff after successful login.
                                            [self dismissViewControllerAnimated:NO completion:nil];
                                            
                                        } else {
                                            // The login failed. Check error to see why.
                                            self.emailField.text = @"";
                                            self.phoneNumberField.text = @"";
                                            self.passwordField.text = @"";
                                            self.emailField.placeholder = @"Email. Please try again!";
                                            self.phoneNumberField.placeholder = @"Phone Number. Please try again!";
                                            self.passwordField.placeholder = @"Password. Please try again!";
                                        }
                                    }];
}

-(void)tappedSignupButton:(id)sender {

    if ((UIButton *)sender == self.signupButton) {
        // signup
        self.loginButton.hidden = YES;
        self.signupButton.hidden = YES;
        self.emailField.hidden = YES;
        self.phoneNumberField.hidden = YES;
        self.passwordField.hidden = YES;
        
        
        [self signUp];
        
    } else {
        User *newUser = [[User alloc] initWithEmail:self.emailField.text andWithPassWord:self.passwordField.text];
        newUser.workoutType = self.workoutType;
        newUser.fullName = self.fullName.text;
        newUser.phoneNumber = self.phoneNumberField.text;
        
        if (self.emailField.text == nil || self.passwordField.text == nil) {
            if (self.emailField.text == nil) {
                self.emailField.placeholder = @"Email. Please try again!";
            } else if (self.passwordField.text == nil) {
                self.passwordField.placeholder = @"Password. Please try again!";
            } else {
                self.emailField.placeholder = @"Email. Please try again!";
                self.passwordField.placeholder = @"Password. Please try again!";
            }
        } else {
            [newUser.parseUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    // Hooray! Let them use the app now.
                    NSLog(@"Success!");
                    [self dismissViewControllerAnimated:NO completion:nil];
                    
                } else {
                    NSString *errorString = [error userInfo][@"error"];
                    
                    // Show the errorString somewhere and let the user try again.
                    NSLog(@"Failure: %@", errorString);
                    self.emailField.placeholder = @"Email. Please try again!";
                    self.phoneNumberField.placeholder = @"Phone Number. Please try again!";
                    self.passwordField.placeholder = @"Password. Please try again!";
                    self.fullName.placeholder = @"Full Name. Please try again!";
                    
                }
            }];
        }
    }
}

-(void)signUp {
    CGPoint center = self.view.center;

    self.weightLiftingButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.weightLiftingButton.frame = CGRectMake(center.x - 75, center.y - 200, 150, 150);
    [self.weightLiftingButton setImage:[UIImage imageNamed:@"icon_44534.png"] forState:UIControlStateNormal];
    [self.weightLiftingButton addTarget:self action:@selector(tappedWorkoutStyleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.weightLiftingButton.tag = 0;
    [self.view addSubview:self.weightLiftingButton];
    
    self.runningButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.runningButton.frame = CGRectMake(center.x - 75, center.y + 50, 150, 150);
    [self.runningButton setImage:[UIImage imageNamed:@"icon_14880.png"] forState:UIControlStateNormal];
    [self.runningButton addTarget:self action:@selector(tappedWorkoutStyleButton:) forControlEvents:UIControlEventTouchUpInside];
    self.runningButton.tag = 1;
    [self.view addSubview:self.runningButton];
}

-(void)tappedWorkoutStyleButton:(UIButton *)sender {
    if ([sender tag] == [self.runningButton tag]) {
        self.workoutType = Running;
        NSLog(@"%d? weight %d, run %d", [sender tag], [self.weightLiftingButton tag], [self.runningButton tag]);
    } else if ([sender tag] == [self.weightLiftingButton tag]) {
        NSLog(@"%d? weight %d, run %d", [sender tag], [self.weightLiftingButton tag], [self.runningButton tag]);
        self.workoutType = Weightlifting;
    }
    
    
    self.weightLiftingButton.hidden = YES;
    self.runningButton.hidden = YES;
    self.emailField.hidden = NO;
    self.phoneNumberField.hidden = NO;
    self.passwordField.hidden = NO;
    
    CGPoint center = self.view.center;
    
    self.fullName = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 160, 300, 40)];
    self.fullName.placeholder = @"Full Name";
    self.fullName.borderStyle = UITextBorderStyleRoundedRect;
    self.fullName.clearButtonMode = YES;
    self.fullName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.view addSubview:self.fullName];
    
    self.phoneNumberField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y, 300, 40)];
    self.phoneNumberField.placeholder = @"Phone Number";
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNumberField.clearButtonMode = YES;
    self.phoneNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.phoneNumberField.delegate = self;
    [self.view addSubview:self.phoneNumberField];
    
    self.emailField.frame = CGRectMake(center.x - 150, center.y - 80, 300, 40);
    self.passwordField.frame = CGRectMake(center.x - 150, center.y + 80, 300, 40);
    
    self.actualSignUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actualSignUpButton.frame = CGRectMake(center.x - 100, center.y + 160, 200, 40);
    [self.actualSignUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.actualSignUpButton addTarget:self action:@selector(tappedSignupButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actualSignUpButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField)
    {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
