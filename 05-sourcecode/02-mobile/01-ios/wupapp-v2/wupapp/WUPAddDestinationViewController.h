//
//  WUPAddDestinationViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Libraries
#import <MapKit/MapKit.h>
//Models
#import "Destination.h"
#import "Destination+Database.h"
//ViewControllers
#import "WUPListSearchEngineResultViewController.h"
//Categories
#import "UITextField+PaddingText.h"



@interface WUPAddDestinationViewController : WUPBaseDatabaseViewController<UITextFieldDelegate,WUPListSearchEngineResultViewControllerDelegate>

@property(strong,nonatomic) Destination* selectedDestination;

@end
