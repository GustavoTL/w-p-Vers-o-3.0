//
//  WUPBaseDatabaseLocalNotificationViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/4/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPBaseDatabaseViewController.h"

//Models
#import "Setting.h"
#import "Setting+Database.h"

@interface WUPBaseDatabaseLocalNotificationViewController : WUPBaseDatabaseViewController


-(void) listScheduledMasterLocalNotifications;
-(void) listScheduledLocalNotifications;
-(void) removeScheduledLocalNotificationsWithId:(NSManagedObjectID*) objectID;
-(BOOL) containsScheduledLocalNotificationsWithId:(NSManagedObjectID*) objectID;

-(void) insertNewWeeklyScheduledLocalNotificationWithDate:(NSDate*) date AndRepeatInterval:(NSString*)repeatInteval AndSound:(NSString*) soundName AndLabel:(NSString*) label AndTimeToLeave:(NSTimeInterval)timeToLeave AndObjectID:(NSManagedObjectID*) objectID;

-(void) cleanIconBadgeNumber;
-(NSArray*) scheduledMasterLocalNotifications;
-(NSArray*) scheduledTimeToLeaveLocalNotifications;

@end
