//
//  WUPListDestinationTableViewCell.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SWTableViewCell.h>
#import <NSMutableArray+SWUtilityButtons.h>

#import "Destination.h"

@interface WUPListDestinationTableViewCell : SWTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UIImageView *checkMarkerImage;

@property (strong, nonatomic) Destination* destination;

@end
