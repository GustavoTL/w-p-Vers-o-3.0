//
//  WUPListAlarmTableTableViewCell.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPListAlarmTableTableViewCell.h"

@implementation WUPListAlarmTableTableViewCell

-(void)awakeFromNib {
    
    //Applying Fonts
    self.whenAlarmLabel.font = [UIFont fontWithName:kPlutoFontNameThin size:40.0f];
    self.destinationDescriptionLabel.font = [UIFont fontWithName:kProximaNovaFontNameBold size:11.5f];
    self.destinationAndRepeatIntervalLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:11.5f];
}

- (IBAction)OnOffChangedValue:(id)sender {
    self.alarm.actived = [NSNumber numberWithBool:self.onOffSwitch.on];
    
    //Changing Color based on Alarm actived property
    if([self.alarm.actived boolValue]) {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:0.212 green:0.267 blue:0.31 alpha:1.0];
        
        self.whenAlarmLabel.textColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        self.destinationDescriptionLabel.textColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        self.destinationAndRepeatIntervalLabel.textColor = [UIColor whiteColor];
    
    } else {
        
        self.contentView.backgroundColor = [UIColor colorWithRed:0.925 green:0.933 blue:0.937 alpha:1.0];
        
        self.whenAlarmLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
        self.destinationDescriptionLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
        self.destinationAndRepeatIntervalLabel.textColor = [UIColor colorWithRed:0.647 green:0.647 blue:0.647 alpha:1.0];
    }
    
    if(self.delegateChanges){
        [self.delegateChanges saveAlarmChanges:self.alarm];
    }
}


@end
