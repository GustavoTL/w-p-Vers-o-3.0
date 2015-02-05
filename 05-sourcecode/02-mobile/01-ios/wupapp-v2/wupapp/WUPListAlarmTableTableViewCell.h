//
//  WUPListAlarmTableTableViewCell.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <SWTableViewCell.h>
#import <NSMutableArray+SWUtilityButtons.h>

//Models
#import "Alarm.h"

@protocol WUPListAlarmTableTableViewCellDelegate <NSObject>

-(void) saveAlarmChanges:(Alarm*) alarm;

@end

@interface WUPListAlarmTableTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *whenAlarmLabel;
@property (weak, nonatomic) IBOutlet UILabel *destinationAndRepeatIntervalLabel;
@property (weak, nonatomic) IBOutlet UISwitch *onOffSwitch;
@property (weak, nonatomic) IBOutlet UILabel *destinationDescriptionLabel;

@property(strong, nonatomic) Alarm* alarm;
@property(strong,nonatomic) id<WUPListAlarmTableTableViewCellDelegate> delegateChanges;

@end
