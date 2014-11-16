//
//  SignInUpViewController.m
//  FitFinder
//
//  Created by Michael Brennan on 10/21/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import "SignInUpViewController.h"
#import "PhotoCell.h"

@interface SignInUpViewController ()

@property UITextField *emailField;
@property UITextField *phoneNumberField;
@property UITextField *passwordField;
@property UIButton *loginButton;
@property UIButton *signupButton;
@property UIButton *actualSignUpButton;

@property UIButton *weightLiftingButton;
@property UIButton *runningButton;
@property Workout workoutType;
@property UITextField *fullName;


//picture stuff
@property (strong, nonatomic) NSArray* photoFileNameArray;
@property (strong, nonatomic) NSString* sourcePath;


@end

@implementation SignInUpViewController

-(instancetype)init {
    if (self = [super init]) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        self.emailField.delegate = self;
        self.phoneNumberField.delegate = self;
        self.passwordField.delegate = self;
        self.fullName.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    
    CGPoint center = self.view.center;
    
    self.emailField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 80, 300, 40)];
    self.emailField.placeholder = @"Email";
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.emailField];
    
    self.phoneNumberField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 80, 300, 40)];
    self.phoneNumberField.placeholder = @"Phone Number";
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.phoneNumberField];
    
    self.passwordField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y, 300, 40)];
    self.passwordField.placeholder = @"Password";
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;
    [self.view addSubview:self.passwordField];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.loginButton.frame = CGRectMake(center.x - 100, center.y + 80, 200, 40);
    [self.loginButton setTitle:@"Login" forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.loginButton];
    
    self.signupButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.signupButton.frame = CGRectMake(center.x - 100, center.y + 120, 200, 40);
    [self.signupButton setTitle:@"or sign up here" forState:UIControlStateNormal];
    [self.signupButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.signupButton];
    
    
    /*
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:_collectionView];
    _collectionView.backgroundColor = [UIColor whiteColor];*/
    [self loadPictures];
    
    
    [super viewDidLoad];

}

-(void)tappedButton:(id)sender {
    
    if ((UIButton *)sender == self.signupButton) {
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [self.view addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    else if ((UIButton *)sender == self.loginButton) {
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
    else {
        User *newUser = [[User alloc] initWithEmail:self.emailField.text andWithPassWord:self.passwordField.text];
        newUser.workoutType = self.workoutType;
        newUser.fullName = self.fullName.text;
        newUser.phoneNumber = self.phoneNumberField.text;
        
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


- (void) loadPictures
{
    // Save our path to the photos.
    self.sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Pictures"];
    // Save photo names in photoArray.
    self.photoFileNameArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.sourcePath error:NULL];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.photoFileNameArray count];
    //return 3;
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSLog(@"Section: %ld, Row: %ld", (long)indexPath.section, (long)indexPath.row);
    [self workoutStyle:indexPath.row];
    
}
- (void) workoutStyle:(NSInteger)selection
{
    NSLog(@"%ld", selection);
    
    if(selection == 0){
        NSLog(@"0");
        self.workoutType = Biking;
    }
    else if(selection == 1){
        NSLog(@"1");
        self.workoutType = Running;
    }
    else{
        NSLog(@"2");
        self.workoutType = Weightlifting;
    }
    CGPoint center = self.view.center;
    
    
    
    _collectionView.hidden = YES;
    self.loginButton.hidden = YES;
    self.signupButton.hidden = YES;
    
    self.fullName = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 160, 300, 40)];
    self.fullName.placeholder = @"Full Name";
    self.fullName.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.fullName];
    
    self.emailField.placeholder = @"Email";
    self.emailField.frame = CGRectMake(center.x - 150, center.y - 80, 300, 40);
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.emailField];
    
    self.phoneNumberField.placeholder = @"Phone Number";
    self.phoneNumberField.frame = CGRectMake(center.x - 150, center.y, 300, 40);
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.phoneNumberField];
    
    self.passwordField.placeholder = @"Password";
    self.passwordField.frame = CGRectMake(center.x - 150, center.y + 80, 300, 40);
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;
    [self.view addSubview:self.passwordField];
    
    self.actualSignUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actualSignUpButton.frame = CGRectMake(center.x - 100, center.y + 160, 200, 40);
    [self.actualSignUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.actualSignUpButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actualSignUpButton];
}


// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get image name and create a file extension for it.
    NSString* imageName = [self.photoFileNameArray objectAtIndex:indexPath.row];
    NSString *filename = [NSString stringWithFormat:@"%@/%@", self.sourcePath, imageName];
    
    
    PhotoCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    //cell.backgroundColor=[UIColor whiteColor];
    
    // Put our images into image views.
    UIImage* image = [UIImage imageWithContentsOfFile:filename];
    //UIImageView* photoImageView = [[UIImageView alloc] initWithImage:image];
    
    cell.imageView.image = image;

    // Add picture to cell as subview
    //[cell addSubview:photoImageView];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width - 150, 250);
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
