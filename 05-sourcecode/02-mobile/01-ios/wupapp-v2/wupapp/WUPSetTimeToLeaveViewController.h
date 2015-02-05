//
//  WUPSetTimeToLeaveViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>

//Models
#import "Setting.h"
#import "Setting+Database.h"

@protocol WUPSetTimeToLeaveViewControllerDelegate <NSObject>

-(void) pickedATimeToleave:(int) seconds;

@end

@interface WUPSetTimeToLeaveViewController : UIViewController

@property(strong,nonatomic) id<WUPSetTimeToLeaveViewControllerDelegate> delegate;
@property(nonatomic) int alreadySelectedTimeToLeave;

@end
