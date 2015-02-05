//
//  UILocalNotification+NextFireDate.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "UILocalNotification+NextFireDate.h"

@implementation UILocalNotification (NextFireDate)

- (NSDate *)nextFireDateAfterDate:(NSDate *)afterDate
{
    // Check if fire date is in the future:
    if ([self.fireDate compare:afterDate] == NSOrderedDescending || self.repeatInterval == 0)
        return self.fireDate;
    
    // The notification can have its own calendar, but the default is the current calendar:
    NSCalendar *cal = self.repeatCalendar;
    if (cal == nil)
        cal = [NSCalendar currentCalendar];
    
    // Number of repeat intervals between fire date and the reference date:
    NSDateComponents *difference = [cal components:self.repeatInterval
                                          fromDate:self.fireDate
                                            toDate:afterDate
                                           options:0];
    
    // Add this number of repeat intervals to the initial fire date:
    NSDate *nextFireDate = [cal dateByAddingComponents:difference
                                                toDate:self.fireDate
                                               options:0];
    
    // If necessary, add one more:
    if ([nextFireDate compare:afterDate] == NSOrderedAscending) {
        switch (self.repeatInterval) {
            case NSWeekCalendarUnit:
                difference.week++;
                break;
            case NSDayCalendarUnit:
                difference.day++;
                break;
            case NSHourCalendarUnit:
                difference.hour++;
                break;
            default:
                break;
        }
        nextFireDate = [cal dateByAddingComponents:difference
                                            toDate:self.fireDate
                                           options:0];
    }
    return nextFireDate;
}

@end
