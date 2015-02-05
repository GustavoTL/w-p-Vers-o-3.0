//
//  UILocalNotification+LastFireDate.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILocalNotification (LastFireDate)

- (NSDate *)lastFireDateBeforeDate:(NSDate *)afterDate;

@end
