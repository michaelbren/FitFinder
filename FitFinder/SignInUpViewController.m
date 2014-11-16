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
    
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    _collectionView=[[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [self.view addSubview:_collectionView];
    
    [self loadPictures];
    [super viewDidLoad];

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

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Get image name and create a file extension for it.
    NSString* imageName = [self.photoFileNameArray objectAtIndex:indexPath.row];
    NSString *filename = [NSString stringWithFormat:@"%@/%@", self.sourcePath, imageName];
    
    
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    
    cell.backgroundColor=[UIColor whiteColor];
    
    // Put our images into image views.
    UIImage* image = [UIImage imageWithContentsOfFile:filename];
    UIImageView* photoImageView = [[UIImageView alloc] initWithImage:image];
    
    // Add picture to cell as subview
    [cell addSubview:photoImageView];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, 250);
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
