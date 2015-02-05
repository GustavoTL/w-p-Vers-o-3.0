//
//  WUPChoseAlarmLabelViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/11/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Categories
#import "UITextField+PaddingText.h"

@protocol WUPChoseAlarmLabelViewControllerDelegate <NSObject>

-(void) pickedALabel:(NSString*) label;

@end

@interface WUPChoseAlarmLabelViewController : UIViewController

@property(strong,nonatomic) id<WUPChoseAlarmLabelViewControllerDelegate> delegate;
@property(strong,nonatomic) NSString* alreadySelectedLabel;

@end
