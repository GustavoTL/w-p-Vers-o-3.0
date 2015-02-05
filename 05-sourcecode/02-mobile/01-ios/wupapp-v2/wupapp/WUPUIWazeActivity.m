//
//  WUPUIWazeActivity.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPUIWazeActivity.h"

@implementation WUPUIWazeActivity


-(NSString *)activityType
{
    return @"br.com.wupapp.wUpApp.Waze.App";
}

-(NSString *)activityTitle{
    return @"Waze";
}

-(UIImage *)_activityImage
{
    return [UIImage imageNamed:@"waze_icon"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s", __FUNCTION__);
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    NSLog(@"%s",__FUNCTION__);
}

- (UIViewController *)activityViewController
{
    NSLog(@"%s",__FUNCTION__);
    return nil;
}

- (void)performActivity
{
    if ([[UIApplication sharedApplication]
         canOpenURL:[NSURL URLWithString:@"waze://"]]) {
        
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes",self.latitude,self.longitude]]];
        
    } else {             
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id323229106"]];
    }
    
    [self activityDidFinish:YES];
}

@end
