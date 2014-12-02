//
//  SignInUpViewController.h
//  FitFinder
//
//  Created by Michael Brennan on 10/21/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "User.h"
#import <CoreLocation/CoreLocation.h>

@interface SignInUpViewController : UIViewController <UITextFieldDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIPickerViewDelegate>
{
    UICollectionView *_collectionView;
}
-(instancetype)init;

@end
