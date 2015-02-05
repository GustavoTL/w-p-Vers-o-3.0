//
//  UILocalNotification+LastFireDate.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "UILocalNotification+LastFireDate.h"

@implementation UILocalNotification (LastFireDate)

- (NSDate *)lastFireDateBeforeDate:(NSDate *)afterDate
{
    NSLog(@"%s - self.fireDate: %@",__PRETTY_FUNCTION__, self.fireDate);
    // Check if fire date is in the future:
    if ([afterDate compare:self.fireDate] == NSOrderedAscending){
//        return self.fireDate;
        return [NSDate dateWithTimeIntervalSince1970:0];
    }
    
    
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
    NSDate *lastFireDate = [cal dateByAddingComponents:difference
                                                toDate:self.fireDate
                                               options:0];
    
    // If necessary, subtract one interval:
    if ([lastFireDate compare:afterDate] == NSOrderedDescending) {
        switch (self.repeatInterval) {
            case NSWeekCalendarUnit:
                difference.week--;
                break;
            case NSDayCalendarUnit:
                difference.day--;
                break;
            case NSHourCalendarUnit:
                difference.hour--;
                break;
            default:
                break;
        }
        lastFireDate = [cal dateByAddingComponents:difference
                                            toDate:self.fireDate
                                           options:0];
    }
    return lastFireDate;
}


@end
