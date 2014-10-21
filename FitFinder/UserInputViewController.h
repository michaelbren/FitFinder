//
//  UserInputViewController.h
//  FitFinder
//
//  Created by Carl Bai on 10/20/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserInputViewController : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTxtField;
@property (weak, nonatomic) IBOutlet UITextField *gymTxtField;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@end
