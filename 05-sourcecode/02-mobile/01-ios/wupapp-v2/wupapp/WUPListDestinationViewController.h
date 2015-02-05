//
//  WUPListDestinationViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WUPListDestinationTableViewCell.h"
#import "Destination+Database.h"

#import "WUPAddDestinationViewController.h"

@protocol WUPListDestinationViewControllerDelegate <NSObject>

-(void) pickedADestination:(Destination*) destination;

@end

@interface WUPListDestinationViewController : WUPBaseDatabaseViewController<UITableViewDelegate,UITableViewDataSource,SWTableViewCellDelegate>

@property (strong, nonatomic) Destination* alreadySelectedDesination;

@property(strong,nonatomic) id<WUPListDestinationViewControllerDelegate> delegate;


@end
