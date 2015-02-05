//
//  WUPAddAlarmViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>

//ViewControllers
#import "WUPChoseSongViewController.h"
#import "WUPChoseWeekdaysViewController.h"
#import "WUPListDestinationViewController.h"
#import "WUPChoseAlarmLabelViewController.h"
#import "WUPSetTimeToLeaveViewController.h"
#import "WUPAddAlarmeContainerViewController.h"

//MOdels
#import "WUPSong.h"
#import "Destination.h"
#import "Alarm.h"
#import "Setting.h"
//Categories
#import "Alarm+Database.h"
#import "Destination+Database.h"
#import "Setting+Database.h"

//Services
#import "WUPNokiaTrafficConditionsService.h"

@interface WUPAddAlarmViewController : WUPBaseDatabaseLocalNotificationViewController < WUPChoseRepeatViewControllerDelegate,
                                                                                        WUPChoseSongViewControllerDelegate,
                                                                                        WUPListDestinationViewControllerDelegate,
    WUPChoseAlarmLabelViewControllerDelegate,
    WUPSetTimeToLeaveViewControllerDelegate,
    CLLocationManagerDelegate>

@property(strong,nonatomic) Alarm* selectedAlarm;

@end
