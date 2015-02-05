//
//  WUPChoseAlarmLabelViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/11/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPChoseAlarmLabelViewController.h"

@interface WUPChoseAlarmLabelViewController()
@property (weak, nonatomic) IBOutlet UITextField *alarmLabelTextField;

@end

@implementation WUPChoseAlarmLabelViewController


#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Choose Label Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI {
    
    //Changing Fonts
    self.alarmLabelTextField.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    [self.alarmLabelTextField setLeftPadding:20];
    
    if(self.alreadySelectedLabel)
    {
        self.alarmLabelTextField.text = self.alreadySelectedLabel;
    }
    
    [self.alarmLabelTextField becomeFirstResponder];
}

#pragma mark - Action methods
- (IBAction)touchUpNavBarCancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)touchUpOkButton:(UIBarButtonItem *)sender {
    
    if(self.alarmLabelTextField.text.length == 0) {
    
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Atenção"
                                                       message:@"Coloque nome da etiqueta"
                                                      delegate:nil
                                             cancelButtonTitle:@"ok"
                                             otherButtonTitles:nil, nil];
    
        [alert show];
        
    } else {
    
        [self.alarmLabelTextField resignFirstResponder];
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            if(self.delegate){
                [self.delegate pickedALabel:self.alarmLabelTextField.text];
            }
        }];
    }
}

@end
