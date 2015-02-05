//
//  WUPChoseWeekdaysViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUPChoseWeekdaysTableViewCell.h"

//@protocol WUPChoseWeekdaysViewControllerDelegate <NSObject>
//
//-(void) pickedRepeatDays:(NSArray*) selectedDaysOfWeek;
//
//@end

@interface WUPChoseWeekdaysViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

//@property (strong,nonatomic) id<WUPChoseWeekdaysViewControllerDelegate> delegate;
@property (strong,nonatomic) NSMutableArray* alreadySelectedDaysOfWeek;
@property(strong,nonatomic) NSMutableArray* arraySelectedDaysOfWeek;

@end
