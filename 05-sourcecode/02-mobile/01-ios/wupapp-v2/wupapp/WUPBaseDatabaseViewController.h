//
//  WUPBaseDatabaseViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WUPAppDelegate.h"


//Models
#import "Alarm.h"
#import "Alarm+Database.h"

@interface WUPBaseDatabaseViewController : UIViewController

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

- (void) updateLocation:(CLLocation*)location;

-(void) setupDatabaseConnection;
-(Alarm*) alarmFromNotificationUserInfo:(NSDictionary*) userInfoDict;

@end
