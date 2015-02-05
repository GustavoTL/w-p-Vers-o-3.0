//
//  WUPChoseWeekdaysTableViewCell.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WUPChoseWeekdaysTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dayOfWeeekLabel;

@property (nonatomic) BOOL checkedIndexPath;

@end
