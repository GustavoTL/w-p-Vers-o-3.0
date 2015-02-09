//
//  WUPBaseDatabaseLocalNotificationViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/4/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPBaseDatabaseLocalNotificationViewController.h"

@interface WUPBaseDatabaseLocalNotificationViewController ()

@end

@implementation WUPBaseDatabaseLocalNotificationViewController

#pragma mark - Local Notifications handling
-(void) listScheduledMasterLocalNotifications
{
#ifdef  DEBUG
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
    
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
        
        NSDictionary* userInfo = local.userInfo;
        
        NSString* master = [userInfo objectForKey:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION]];
        if(master){
            NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
        }
        
    }
    
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
}

-(void) listScheduledLocalNotifications
{
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
    
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];

            NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
        
    }
    
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
}

-(void) removeScheduledLocalNotificationsWithId:(NSManagedObjectID*) objectID
{
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
#endif
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
#ifdef  __DEBUG_FINEST__
        NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
#endif
        NSDictionary* userInfo = local.userInfo;
        
        if([[userInfo objectForKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]] isEqualToString:objectID.URIRepresentation.absoluteString] &&
           [[userInfo objectForKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]] isEqualToString:objectID.URIRepresentation.lastPathComponent]){
#ifdef  __DEBUG_FINEST__
            NSLog(@"%s Found one notification with this ID",__PRETTY_FUNCTION__);
#endif
            [[UIApplication sharedApplication] cancelLocalNotification:local];
        }
    }
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
    
}

-(BOOL) containsScheduledLocalNotificationsWithId:(NSManagedObjectID*) objectID
{
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
#endif
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
#ifdef  __DEBUG_FINEST__
        NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
#endif
        NSDictionary* userInfo = local.userInfo;
        
        if([[userInfo objectForKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]] isEqualToString:objectID.URIRepresentation.absoluteString] &&
           [[userInfo objectForKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]] isEqualToString:objectID.URIRepresentation.lastPathComponent]){
#ifdef  __DEBUG_FINEST__
            NSLog(@"%s Found one notification with this ID",__PRETTY_FUNCTION__);
#endif
            return  YES;
        }
    }
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
    return NO;
    
}

-(void) insertNewScheduledLocalNotificationWithDate:(NSDate*) date AndRepeatInterval:(NSCalendarUnit)repeatInteval AndSound:(NSString*) soundName AndLabel:(NSString*) label AndTimeToLeave:(NSTimeInterval)timeToLeave AndObjectID:(NSManagedObjectID*) objectID
{
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
#endif
    NSDate* originalDate = date;
    
    int totlaNotification = [WUPConstants NUMBER_REPEAT_ALARMS];
    
    if(timeToLeave == 0) {
        
        totlaNotification = 1;
    }
    
    for(int i = 0; i < totlaNotification; i++) {
     
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] init];
        [userInfo setObject:objectID.URIRepresentation.absoluteString forKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]];
        [userInfo setObject:objectID.URIRepresentation.lastPathComponent forKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]];
        
        NSString* message;
        NSDate* dateToFire;
        
        //message = [NSString stringWithFormat:@"[%@] - É hora de acordar!",label];
        message = [NSString stringWithFormat:NSLocalizedString(@"alert_sair", nil), ((int)timeToLeave / 60)];
        
        dateToFire = date;
        
        if(i == 0 && timeToLeave > 0) {
            
            [userInfo setObject:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION] forKey:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION]];
        
        } else if (i == totlaNotification - 1) {
            
            [userInfo setObject:[WUPConstants OBJECT_TIMETOLEAVE_LOCALNOTIFICATION] forKey:[WUPConstants OBJECT_TIMETOLEAVE_LOCALNOTIFICATION]];
            message = [NSString stringWithFormat:NSLocalizedString(@"alert_hora_sair", nil),label];
            
            dateToFire = [originalDate dateByAddingTimeInterval:timeToLeave];
            
        }
        
        NSLog(@"repeatInteval %lu", repeatInteval);
                
        UILocalNotification* ln = [[UILocalNotification alloc] init];
        ln.soundName = soundName;
        ln.timeZone = [NSTimeZone defaultTimeZone];
        ln.alertBody = message;
        ln.applicationIconBadgeNumber = i ;
        ln.fireDate = dateToFire;
        ln.repeatInterval = repeatInteval;
        ln.userInfo = userInfo;
        
        [[UIApplication sharedApplication] scheduleLocalNotification:ln];
        
#ifdef  DEBUG
        NSLog(@"%s scheduling:i:%d fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,i,ln.fireDate, ln.soundName, (long)ln.repeatInterval);
#endif
        
        //date = [date dateByAddingTimeInterval:40]; //Adding 40 seconds interval from on local notification to another
        
    }
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
}

-(void) insertNewWeeklyScheduledLocalNotificationWithDate:(NSDate*) date AndRepeatInterval:(NSString*)repeatInteval AndSound:(NSString*) soundName AndLabel:(NSString*) label AndTimeToLeave:(NSTimeInterval)timeToLeave AndObjectID:(NSManagedObjectID*) objectID {

    NSLocale *ptLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
    NSDateFormatter* dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setLocale:ptLocale];
    [dateformatter setDateFormat:@"EEEE"];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    if(![repeatInteval isEqualToString:@""]) {
        
        NSArray* repeatDays = [repeatInteval componentsSeparatedByString:@", "];
    
        NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit
                                              fromDate:date];
        
        for(NSString* weekday in repeatDays) {
            
            //NSLog(@"%s weekdayStr: %@ weekDay: %d",__PRETTY_FUNCTION__,weekday, [WUPConstants WEEKDAYNUMBER_FORWEEKDAY:weekday]);
            [comps setWeekday:[WUPConstants WEEKDAYNUMBER_FORWEEKDAY:weekday]];
            NSDate* dateNew = [calendar dateFromComponents:comps];
            NSLog(@"%s dateNew: %@",__PRETTY_FUNCTION__,dateNew);
            
            [self insertNewScheduledLocalNotificationWithDate:dateNew
                                            AndRepeatInterval:NSWeekCalendarUnit
                                                     AndSound:soundName
                                                     AndLabel:label
                                               AndTimeToLeave:timeToLeave
                                                  AndObjectID:objectID];
        }
    
    } else {
        
        NSDate* dataToBeScheduled = date;
        
        if ([dataToBeScheduled compare:[NSDate date]] == NSOrderedAscending) {
            
            NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|
                                                                                NSDayCalendarUnit|
                                                                                NSWeekCalendarUnit|
                                                                                NSWeekdayCalendarUnit|
                                                                                NSHourCalendarUnit|
                                                                                NSMinuteCalendarUnit|
                                                                                NSSecondCalendarUnit
                                                  fromDate:[NSDate date]];
            
            NSDateComponents *hourMinuteSecondComponents = [calendar components:NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:dataToBeScheduled];

            [hourMinuteSecondComponents setYear:comps.year];
            [hourMinuteSecondComponents setMonth:comps.month];
            [hourMinuteSecondComponents setDay:comps.day];
            
            dataToBeScheduled = [calendar dateFromComponents:hourMinuteSecondComponents];
            
            if([dataToBeScheduled compare:[NSDate date]] == NSOrderedAscending) {
                
                hourMinuteSecondComponents.day++;
                dataToBeScheduled = [calendar dateFromComponents:hourMinuteSecondComponents];
            }
        }

        [self insertNewScheduledLocalNotificationWithDate:dataToBeScheduled
                                        AndRepeatInterval:0
                                                 AndSound:soundName
                                                 AndLabel:label
                                           AndTimeToLeave:timeToLeave
                                              AndObjectID:objectID];
    }
}

-(void) cleanIconBadgeNumber{
    [UIApplication sharedApplication].applicationIconBadgeNumber  = 0;
}

-(NSArray*) scheduledMasterLocalNotifications
{
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
#endif
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray* arrayFoundNotifications = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [arrayNotifications count]; i++){
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
#ifdef  __DEBUG_FINEST__
        NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
#endif
        NSDictionary* userInfo = local.userInfo;
        
        NSString* master = [userInfo objectForKey:[WUPConstants OBJECT_MASTER_LOCALNOTIFICATION]];
        if(master){
#ifdef  __DEBUG_FINEST__
            NSLog(@"%s Found one master notification ",__PRETTY_FUNCTION__);
#endif
            [arrayFoundNotifications addObject:local];
        }
    }
#ifdef  __DEBUG_FINEST__
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
    return arrayFoundNotifications;
}

-(NSArray*) scheduledTimeToLeaveLocalNotifications {
    
#ifdef  DEBUG
    NSLog(@"%s - Start",__PRETTY_FUNCTION__);
#endif
    NSArray* arrayNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    NSMutableArray* arrayFoundNotifications = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < [arrayNotifications count]; i++) {
        UILocalNotification *local = [arrayNotifications objectAtIndex:i];
#ifdef  __DEBUG_FINEST__
        NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
#endif
        NSDictionary* userInfo = local.userInfo;
        
        NSString* master = [userInfo objectForKey:[WUPConstants OBJECT_TIMETOLEAVE_LOCALNOTIFICATION]];
        if(master){
#ifdef  DEBUG
//            NSLog(@"%s Found one time to leave notification ",__PRETTY_FUNCTION__);
            NSLog(@"%s fireDate:%@ soundName:%@ repeatInterval:%lu",__PRETTY_FUNCTION__,local.fireDate, local.soundName, (long)local.repeatInterval);
#endif
            [arrayFoundNotifications addObject:local];
        }
    }
#ifdef  DEBUG
    NSLog(@"%s - End",__PRETTY_FUNCTION__);
#endif
    return arrayFoundNotifications;
}

@end
