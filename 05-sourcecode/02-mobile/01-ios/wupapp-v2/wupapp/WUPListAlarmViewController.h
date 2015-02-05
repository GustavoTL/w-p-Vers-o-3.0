//
//  WUPListAlarmViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <MBProgressHUD/MBProgressHUD.h>

#import "WUPListAlarmTableTableViewCell.h"
#import "WUPAddAlarmViewController.h"

//Models
#import "Alarm.h"
#import "Destination.h"
#import "Setting.h"

#import "Alarm+Database.h"
#import "Setting+Database.h"

//Services
#import "WUPNokiaTrafficConditionsService.h"

//Categories
#import "NSString+NSString_Extended.h"

@interface WUPListAlarmViewController : WUPBaseDatabaseLocalNotificationViewController<UITableViewDataSource,UITableViewDelegate,SWTableViewCellDelegate,WUPListAlarmTableTableViewCellDelegate,CLLocationManagerDelegate>

@end
