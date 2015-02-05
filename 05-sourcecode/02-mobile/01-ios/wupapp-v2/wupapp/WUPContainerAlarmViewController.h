//
//  WUPContainerAlarmViewController.h
//  wUpApp
//
//  Created by Adriano-Dcanm on 2/2/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WUPChoseWeekdaysViewController.h"
#import "WUPAddAlarmCalendarViewController.h"

@interface WUPContainerAlarmViewController : UIViewController

@property (strong, nonatomic) WUPChoseWeekdaysViewController *choseWeekdaysTVC;
@property (strong, nonatomic) WUPChooseDayCalendarViewController *addAlarmCalendarTVC;

@property (strong,nonatomic) NSMutableArray* alreadySelectedDaysOfWeek;

- (void)viewControllersDidSwapWithSelectedIndex:(NSInteger)selectedIndex;

- (NSArray*)repeatDays;
- (NSDate*) calendarDaySelected;

@end
