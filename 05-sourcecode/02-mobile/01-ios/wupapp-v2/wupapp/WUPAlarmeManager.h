//
//  WUPAlarmeManager.h
//  wUpApp
//
//  Created by adriano.mazucato on 27/02/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "Alarm.h"
#import "Destination.h"

@interface WUPAlarmeManager : NSObject

@property (nonatomic, strong) UILocalNotification *nextLocationNotification;
@property (nonatomic, strong) CLLocation *location;


+ (WUPAlarmeManager *)sharedInstance;
- (UILocalNotification*) nextLocalNotification;
- (void) updateTrafficToNextLocationNotification;

@end
