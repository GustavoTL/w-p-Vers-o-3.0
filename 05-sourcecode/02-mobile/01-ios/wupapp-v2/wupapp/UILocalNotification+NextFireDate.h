//
//  UILocalNotification+NextFireDate.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUPDateUtils.h"

@interface UILocalNotification (NextFireDate)

- (NSDate *)nextFireDateAfterDate:(NSDate *)afterDate;

@end
