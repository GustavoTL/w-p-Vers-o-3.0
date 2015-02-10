//
//  WUPHomeViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Libraries
#import <CoreLocation/CoreLocation.h>
#import <AFNetworking/AFNetworking.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <MediaPlayer/MediaPlayer.h>

//Categories
#import "UILocalNotification+NextFireDate.h"

//Models
#import "Alarm.h"
#import "Destination.h"
#import "Setting.h"
#import "Alarm+Database.h"
#import "Destination+Database.h"
#import "Setting+Database.h"

//Services
#import "WUPNokiaTrafficConditionsService.h"

//Other
#import "WUPDateUtils.h"

@interface WUPHomeViewController : WUPBaseDatabaseLocalNotificationViewController<CLLocationManagerDelegate>

-(void) updateNextLocalNotification;
-(void) updateTrafficToNextLocationNotification;

@end
