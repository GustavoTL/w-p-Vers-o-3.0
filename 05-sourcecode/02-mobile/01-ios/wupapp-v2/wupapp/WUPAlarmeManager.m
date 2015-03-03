//
//  WUPAlarmeManager.m
//  wUpApp
//
//  Created by adriano.mazucato on 27/02/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPAlarmeManager.h"
#import "WUPNokiaTrafficConditionsService.h"
#import "UILocalNotification+NextFireDate.h"
static WUPAlarmeManager *sharedAlarmManager;

@implementation WUPAlarmeManager


+ (WUPAlarmeManager *)sharedInstance {
    if (sharedAlarmManager == nil) {
       
        sharedAlarmManager = [[super allocWithZone:NULL] init];
    }
    
    return sharedAlarmManager;
}

- (NSManagedObjectContext*)managerContext {

    WUPAppDelegate * appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = appDelegate.managedObjectContext;
    
    return managedObjectContext;
}

-(Alarm*) alarmFromNotificationUserInfo:(NSDictionary*) userInfoDict {
    
    @try {
        
        NSURL *reconstructedClassURL = [NSURL URLWithString:[userInfoDict objectForKey:[WUPConstants OBJECT_ABSOLUTEURL_LOCALNOTIFICATION]]];
        NSURL *reconstructedInstanceURL = [reconstructedClassURL URLByAppendingPathComponent:[userInfoDict objectForKey:[WUPConstants OBJECT_LASTPATH_LOCALNOTIFICATION]]];
        NSManagedObjectID *objectID = [[self managerContext].persistentStoreCoordinator managedObjectIDForURIRepresentation:reconstructedInstanceURL];
        Alarm  *alarm = (Alarm*)[[self managerContext] objectWithID:objectID];
        return alarm;
        
    }
    @catch (NSException *exception) {
        return nil;
    }
    
}

- (UILocalNotification*) nextLocalNotification {
    
    NSDate* date = [NSDate date];
    //    NSLog(@"%s dateUTC: %@",__PRETTY_FUNCTION__,[WUPDateUtils convertDateInUTCString:date]);
    
    //Checking LocalNotifications
    NSArray* arrayNotifications = [self scheduledTimeToLeaveLocalNotifications];
    
    if([arrayNotifications count]) {
        
        NSArray *sorted = [arrayNotifications sortedArrayUsingComparator:^NSComparisonResult(UILocalNotification *obj1, UILocalNotification *obj2) {
            NSDate *next1 = [obj1 nextFireDateAfterDate:date];
            NSDate *next2 = [obj2 nextFireDateAfterDate:date];
            //            NSLog(@"%s next1: %@ next2: %@",__PRETTY_FUNCTION__,next1,next2);
            return [next1 compare:next2];
        }];
        
        self.nextLocationNotification = [sorted firstObject];
        return self.nextLocationNotification;
        
    } else {
        
        self.nextLocationNotification = nil;
        return nil;
    }
}

-(void) updateTrafficToNextLocationNotification {
    
    self.nextLocationNotification = [self nextLocalNotification];
    
    if(self.nextLocationNotification) {
        
        NSDictionary* userInfoDict = self.nextLocationNotification.userInfo;
        Alarm  *alarm = [self alarmFromNotificationUserInfo:userInfoDict];
        
        WUPNokiaTrafficConditionsService* trafficService = [[WUPNokiaTrafficConditionsService alloc]init];
        
        [trafficService calculateRouteTravelTimeUsing:self.location.coordinate
                                       AndDestination:CLLocationCoordinate2DMake([alarm.destination.latitude doubleValue],[alarm.destination.longitude doubleValue])
                                              success:^(int ETATime, int distancewwww) {
                                                  
                                                  alarm.etaTime = [NSNumber numberWithInt:ETATime];
                                                  [[self managerContext] save:nil];
                                                  
//                                                  NSDate *newDate = [[NSDate date] dateByAddingTimeInterval:1];//-60*15
//                                                  NSDateFormatter *formatter3 = [[NSDateFormatter alloc] init];
//                                                  
//                                                  // [formatter3 setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
//                                                  [formatter3 setTimeStyle:NSDateFormatterShortStyle];
//                                                  [formatter3 setDateStyle:NSDateFormatterShortStyle];
//                                                  
//                                                  NSString *detailstext = [formatter3 stringFromDate:newDate];
//                                                  NSDate *othernewdate = [formatter3 dateFromString:detailstext];
//                                                  
//                                                  UILocalNotification *notification = [[UILocalNotification alloc] init];
//                                                  notification.timeZone = [NSTimeZone systemTimeZone];
//                                                  notification.fireDate = othernewdate;
//                                                  notification.alertBody = [NSString stringWithFormat:@"Recalculado -> %d", ETATime];
//                                                  notification.soundName = UILocalNotificationDefaultSoundName;
//                                                  notification.hasAction = YES;
//                                                  notification.alertAction = NSLocalizedString(@"View", @"View notification button");
//                                                  
//                                                  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
                                                  
                                                  [self successOnCalculateTrafficTimeWithAlarm:alarm AndETATime:ETATime];
                                                  
                                              } failure:^{
                                                  //[self failureOnCalculateTrafficTimeWithAlarm:alarm];
                                              }];
    }
}

-(void) successOnCalculateTrafficTimeWithAlarm:(Alarm*) alarm AndETATime:(int) ETATime
{
    NSTimeInterval timeToLeave = [alarm.timeToLeave intValue];
    
    NSLog(@"%s Date Before Traffic: %@",__PRETTY_FUNCTION__,alarm.whenTime);
    NSDate* date = [alarm.whenTime dateByAddingTimeInterval:(ETATime * -1)];
    date = [date dateByAddingTimeInterval:timeToLeave * -1];
    
    NSLog(@"%s Date After Traffic: %@",__PRETTY_FUNCTION__,date);
    [self commonOnCalculateTrafficTimeWithDate:date AndAlarm:alarm];
}

-(void) commonOnCalculateTrafficTimeWithDate:(NSDate*) date AndAlarm:(Alarm*) alarm {
    //    NSLog(@"%s date: %@",__PRETTY_FUNCTION__,date);
    
    // Only try to replace alarm if this alarm isn't set for never repeating
    if(![alarm.repeatsFor isEqualToString:@""]){
        
        [self removeScheduledLocalNotificationsWithId:alarm.objectID];
        
        //Inserting new LocalNotification
        [self insertNewWeeklyScheduledLocalNotificationWithDate:date
                                              AndRepeatInterval:alarm.repeatsFor
                                                       AndSound:[NSString stringWithFormat:@"%@.%@",alarm.soundFilename,alarm.soundExtension]
                                                       AndLabel:alarm.label
                                                 AndTimeToLeave:[alarm.timeToLeave intValue]
                                                    AndObjectID:alarm.objectID];
    }
}

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

-(void) insertNewScheduledLocalNotificationWithDate:(NSDate*) date AndRepeatInterval:(NSCalendarUnit)repeatInteval AndSound:(NSString*) soundName AndLabel:(NSString*) label AndTimeToLeave:(NSTimeInterval)timeToLeave AndObjectID:(NSManagedObjectID*) objectID {
    
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
        
        date = [date dateByAddingTimeInterval:40]; //Adding 40 seconds interval from on local notification to another
        
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
