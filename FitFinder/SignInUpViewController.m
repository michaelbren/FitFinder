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
@property UITextField *fullName;

@property UIButton *loginButton;
@property UIButton *signupButton;
@property UIButton *actualSignUpButton;

@property UIButton *weightLiftingButton;
@property UIButton *runningButton;
@property Workout workoutType;

@property UIImageView *dot;


@property UIDatePicker *datePicker;
@property UIPickerView *nPicker;

@property UITextField *startTime;
@property UITextField *endTime;
@property UITextField *gym;

@property UIButton *nearbyButton;
@property UIButton *selectBackButton;
@property UIButton *cviewBackButton;
//picture stuff
@property (strong, nonatomic) NSArray* photoFileNameArray;
@property (strong, nonatomic) NSString* sourcePath;



@property (strong, nonatomic) NSMutableArray* nearbyArray;
@property (strong, nonatomic) CLLocationManager *locationManager;

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
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [self.locationManager startUpdatingLocation];
    self.nearbyArray = [[NSMutableArray alloc] init];

    CGPoint center = self.view.center;
    
    self.dot =[[UIImageView alloc] initWithFrame:CGRectMake(center.x-75,center.y - 250,150,150)];
    self.dot.image=[UIImage imageNamed:@"fitfinder.png"];
    [self.view addSubview:self.dot];
    
    
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
    
    //Loads pictures for CollectionView
    [self loadPictures];
    
    // Delegate setting
    self.emailField.delegate = self;
    self.passwordField.delegate = self;
    self.fullName.delegate = self;
}

//Used for location debugging
- (NSString *)deviceLocation {
    return [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
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
        self.dot.hidden = YES;
        
        //[self signUp];
        
        //Load up the collection View
        UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
        _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        
        [_collectionView registerClass:[PhotoCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
        [self.view addSubview:_collectionView];
        _collectionView.backgroundColor = [UIColor whiteColor];
        self.cviewBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cviewBackButton.frame = CGRectMake(0, 5, 60, 40);
        [self.cviewBackButton setTitle:@"Back" forState:UIControlStateNormal];
        [self.cviewBackButton addTarget:self action:@selector(cViewBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.cviewBackButton];
        
        
        
        //Decided to query for nearby gyms when user presses signup just in case it takes a while...
        //queries for nearby gyms
        MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake(self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude);
        
        //CLLocationCoordinate2D location = CLLocationCoordinate2DMake(30.284926,-97.735441);
        request.naturalLanguageQuery = @"gym";
        request.region = MKCoordinateRegionMakeWithDistance(location, 1000, 1000);
        MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
        [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
            for (MKMapItem *item in response.mapItems) {
                NSLog(@"%@", item.name);
                [self.nearbyArray addObject:item.name];
                NSLog(@"Hello, %@", self.nearbyArray[0]);
            }
        }];
        
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

//Load the nearby gyms into a pickerview
-(void)tappedNearbyButton:(id)sender {
    NSLog(@"%@", [self deviceLocation]);
    
    
    NSLog(@"nearbyButton is pressed");
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
    
    UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
    //darkView.alpha = 0;
    //darkView.backgroundColor = [UIColor whiteColor];
    darkView.tag = 9;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
    [darkView addGestureRecognizer:tapGesture];
    [self.view addSubview:darkView];
    
    
    UIPickerView *nPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
    nPicker.tag = 10;
    [self.view addSubview:nPicker];
    nPicker.delegate = self;
    nPicker.showsSelectionIndicator = YES;
    nPicker.backgroundColor = [UIColor grayColor];
    
    
    
    UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
    toolBar.tag = 11;
    toolBar.barStyle = UIBarStyleBlackTranslucent;
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
    [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
    [self.view addSubview:toolBar];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    toolBar.frame = toolbarTargetFrame;
    nPicker.frame = datePickerTargetFrame;
    darkView.alpha = 0.5;
    [UIView commitAnimations];
    
    
    self.gym.text = self.nearbyArray[0];
}


-(void)selectionBackButtonTapped:(id)sender {
    NSLog(@"back");
    
    _collectionView.hidden = NO;
    self.fullName.hidden = YES;
    self.phoneNumberField.hidden = YES;
    self.startTime.hidden = YES;
    self.endTime.hidden = YES;
    self.nearbyButton.hidden = YES;
    self.gym.hidden = YES;
    self.actualSignUpButton.hidden = YES;
    self.selectBackButton.hidden = YES;
}

-(void)cViewBackButtonTapped:(id)sender {
    NSLog(@"back");
    _collectionView.hidden = YES;
    self.loginButton.hidden = NO;
    self.signupButton.hidden = NO;
    self.emailField.hidden = NO;
    self.passwordField.hidden = NO;
    self.dot.hidden = NO;
    self.cviewBackButton.hidden = YES;
    
    //Reposition the email
    CGPoint center = self.view.center;
    self.emailField.frame = CGRectMake(center.x - 150, center.y - 80, 300, 40);
}



/*
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
    
    
}*/

//CollectionView methods
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
    
    self.emailField.hidden = NO;
    self.passwordField.hidden = NO;
    /*
    
    self.emailField.placeholder = @"Email";
    self.emailField.frame = CGRectMake(center.x - 150, center.y - 160, 300, 40);
    self.emailField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.emailField];
    
    self.phoneNumberField.placeholder = @"Phone Number";
    self.phoneNumberField.frame = CGRectMake(center.x - 150, center.y - 80, 300, 40);
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    [self.view addSubview:self.phoneNumberField];
    
    self.passwordField.placeholder = @"Password";
    self.passwordField.frame = CGRectMake(center.x - 150, center.y, 300, 40);
    self.passwordField.borderStyle = UITextBorderStyleRoundedRect;
    self.passwordField.secureTextEntry = YES;
    [self.view addSubview:self.passwordField];*/
    
    
    self.fullName = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 240, 300, 40)];
    self.fullName.placeholder = @"Full Name";
    self.fullName.borderStyle = UITextBorderStyleRoundedRect;
    self.fullName.clearButtonMode = YES;
    self.fullName.autocapitalizationType = UITextAutocapitalizationTypeWords;
    [self.view addSubview:self.fullName];
    
    self.phoneNumberField = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y - 80, 300, 40)];
    self.phoneNumberField.placeholder = @"Phone Number";
    self.phoneNumberField.borderStyle = UITextBorderStyleRoundedRect;
    self.phoneNumberField.clearButtonMode = YES;
    self.phoneNumberField.keyboardType = UIKeyboardTypeNamePhonePad;
    self.phoneNumberField.delegate = self;
    [self.view addSubview:self.phoneNumberField];
    
    self.emailField.frame = CGRectMake(center.x - 150, center.y - 160, 300, 40);
    self.passwordField.frame = CGRectMake(center.x - 150, center.y, 300, 40);
    
    self.actualSignUpButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.actualSignUpButton.frame = CGRectMake(center.x - 100, center.y + 240, 200, 40);
    [self.actualSignUpButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.actualSignUpButton addTarget:self action:@selector(tappedSignupButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.actualSignUpButton];
    
    self.nearbyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.nearbyButton.frame = CGRectMake(center.x, center.y + 160, 200, 40);
    [self.nearbyButton setTitle:@"Nearby" forState:UIControlStateNormal];
    [self.nearbyButton addTarget:self action:@selector(tappedNearbyButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.nearbyButton];
    
    self.startTime = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y + 80, 145, 40)];
    self.startTime.placeholder = @"Preferred Start";
    self.startTime.borderStyle = UITextBorderStyleRoundedRect;
    self.startTime.tag = 4;
    self.startTime.delegate = self;
    [self.view addSubview:self.startTime];
    
    self.endTime = [[UITextField alloc] initWithFrame: CGRectMake(center.x, center.y + 80, 150, 40)];
    self.endTime.placeholder = @"Preferred End";
    self.endTime.borderStyle = UITextBorderStyleRoundedRect;
    self.endTime.tag = 5;
    self.endTime.delegate = self;
    [self.view addSubview:self.endTime];
    
    self.gym = [[UITextField alloc] initWithFrame: CGRectMake(center.x - 150, center.y + 160, 200, 40)];
    self.gym.placeholder = @"Preferred Gym";
    self.gym.borderStyle = UITextBorderStyleRoundedRect;
    self.gym.tag = 6;
    [self.view addSubview:self.gym];
    self.gym.delegate = self;
    
    self.selectBackButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.selectBackButton.frame = CGRectMake(0, 5, 60, 40);
    [self.selectBackButton setTitle:@"Back" forState:UIControlStateNormal];
    [self.selectBackButton addTarget:self action:@selector(selectionBackButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.selectBackButton];
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

//DatePicker methods
- (void)changeDate:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *newTime = [timeFormatter stringFromDate:sender.date] ;
    
    
    self.startTime.text = newTime;
    
}

- (void)changeDate1:(UIDatePicker *)sender {
    NSLog(@"New Date: %@", sender.date);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    [timeFormatter setDateFormat:@"HH:mm"];
    [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *newTime = [timeFormatter stringFromDate:sender.date] ;
    
    
    self.endTime.text = newTime;
    
    
}

- (void)removeViews:(id)object {
    [[self.view viewWithTag:9] removeFromSuperview];
    [[self.view viewWithTag:10] removeFromSuperview];
    [[self.view viewWithTag:11] removeFromSuperview];
}

- (void)dismissDatePicker:(id)sender {
    CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height, 320, 44);
    CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height+44, 320, 216);
    [UIView beginAnimations:@"MoveOut" context:nil];
    [self.view viewWithTag:9].alpha = 0;
    [self.view viewWithTag:10].frame = datePickerTargetFrame;
    [self.view viewWithTag:11].frame = toolbarTargetFrame;
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(removeViews:)];
    [UIView commitAnimations];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"%ld", textField.tag);
    
    //[textField resignFirstResponder];
    if(textField.tag == 4 || textField.tag == 5)
    {
        NSLog(@"Hello world");
        [textField resignFirstResponder];
        if ([self.view viewWithTag:9]) {
            return;
        }
        
        CGRect toolbarTargetFrame = CGRectMake(0, self.view.bounds.size.height-216-44, 320, 44);
        CGRect datePickerTargetFrame = CGRectMake(0, self.view.bounds.size.height-216, 320, 216);
        
        UIView *darkView = [[UIView alloc] initWithFrame:self.view.bounds];
        //darkView.alpha = 0;
        //darkView.backgroundColor = [UIColor whiteColor];
        darkView.tag = 9;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDatePicker:)] ;
        [darkView addGestureRecognizer:tapGesture];
        [self.view addSubview:darkView];
        
        
        
        
        
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height+44, 320, 216)];
        datePicker.datePickerMode = UIDatePickerModeTime;
        datePicker.tag = 10;
        
        if(textField.tag == 4)
        {
            [datePicker addTarget:self action:@selector(changeDate:) forControlEvents:UIControlEventValueChanged];
        }
        else if(textField.tag == 5)
        {
            [datePicker addTarget:self action:@selector(changeDate1:) forControlEvents:UIControlEventValueChanged];
        }
        
        [self.view addSubview:datePicker];
        datePicker.backgroundColor = [UIColor grayColor];
        
        
        
        UIToolbar *toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, 320, 44)];
        toolBar.tag = 11;
        toolBar.barStyle = UIBarStyleBlackTranslucent;
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissDatePicker:)];
        [toolBar setItems:[NSArray arrayWithObjects:spacer, doneButton, nil]];
        [self.view addSubview:toolBar];
        
        [UIView beginAnimations:@"MoveIn" context:nil];
        toolBar.frame = toolbarTargetFrame;
        datePicker.frame = datePickerTargetFrame;
        darkView.alpha = 0.5;
        [UIView commitAnimations];
        
        
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        [timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *newTime = [timeFormatter stringFromDate:datePicker.date] ;
        
        
        [textField setText:newTime];
    }
}




- (void)pickerView:(UIPickerView *)pickerView didSelectRow: (NSInteger)row inComponent:(NSInteger)component {
    // Handle the selection
    NSLog(@"handle the selection");
    self.gym.text = self.nearbyArray[row];
}

// tell the picker how many rows are available for a given component
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    //NSUInteger numRows = 5;
    
    return self.nearbyArray.count;
}

// tell the picker how many components it will have
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

// tell the picker the title for a given component
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSString *title;
    title = self.nearbyArray[row];
    
    return title;
}

// tell the picker the width of each row for a given component
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    int sectionWidth = 300;
    
    return sectionWidth;
}


@end