//
//  MatchViewController.h
//  FitFinder
//
//  Created by Michael Brennan on 10/21/14.
//  Copyright (c) 2014 FitFinder. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "User.h"

@interface MatchViewController : UIViewController
- (instancetype) initWithCurrentUser:(User *)user;
@end
