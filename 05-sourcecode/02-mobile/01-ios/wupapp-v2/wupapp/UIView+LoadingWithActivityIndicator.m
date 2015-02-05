//
//  UIView+LoadingWithActivityIndicator.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/6/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "UIView+LoadingWithActivityIndicator.h"

@implementation UIView (LoadingWithActivityIndicator)

-(void) startLoadingAnimation
{
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    [activityIndicator setFrame:CGRectMake((self.frame.size.width - activityIndicator.frame.size.width) / 2 , (self.frame.size.height - activityIndicator.frame.size.height) / 2 , activityIndicator.frame.size.width , activityIndicator.frame.size.width)];
    
    
    for(UIView* view in self.subviews)
    {
        [view setHidden:YES];
    }
    
    
    
    [self addSubview:activityIndicator];
    
    [activityIndicator startAnimating];
}

-(void) stopLoadingAnimation
{
    
    for(UIView* view in self.subviews)
    {
        if([view isKindOfClass:[UIActivityIndicatorView class]])
        {
            UIActivityIndicatorView* activityIndicator = (UIActivityIndicatorView*)view;
            [activityIndicator stopAnimating];
            [activityIndicator removeFromSuperview];
            
        }
        else
        {
            [view setHidden:NO];
        }
    }
    
}

@end
