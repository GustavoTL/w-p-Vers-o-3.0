//
//  WUPAddAlarmeContainerViewController.h
//  wUpApp
//
//  Created by Adriano-Dcanm on 2/2/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WUPChoseRepeatViewControllerDelegate <NSObject>

-(void) pickedRepeatDays:(NSArray*) selectedDaysOfWeek;
-(void) pickedCalendarDay:(NSDate*) selectedDate;

@end

@interface WUPAddAlarmeContainerViewController : UIViewController

@property (strong,nonatomic) NSMutableArray* alreadySelectedDaysOfWeek;
@property (strong,nonatomic) id<WUPChoseRepeatViewControllerDelegate> delegate;

@end
