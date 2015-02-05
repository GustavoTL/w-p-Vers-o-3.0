//
//  WUPUIGoogleMapsActivity.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPUIGoogleMapsActivity.h"

@implementation WUPUIGoogleMapsActivity

-(NSString *)activityType
{
    return @"br.com.wupapp.wUpApp.GMaps.App";
}

-(NSString *)activityTitle{
    return @"Google Maps";
}

-(UIImage *)_activityImage
{
    return [UIImage imageNamed:@"maps_icon"];
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
    
    if ([[UIApplication sharedApplication] canOpenURL:
         [NSURL URLWithString:@"comgooglemaps://"]]) {
        [[UIApplication sharedApplication] openURL:
         [NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?saddr=&daddr=%f,%f&directionsmode=driving",self.latitude,self.longitude]]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL
                                                    URLWithString:@"http://itunes.apple.com/us/app/id585027354"]];
    }
    
    [self activityDidFinish:YES];
}


@end
