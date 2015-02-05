//
//  WUPChoseSongViewController.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <UIKit/UIKit.h>

//Libraries
#import <AVFoundation/AVAudioPlayer.h>
//TableCell
#import "WUPChoseSongTableViewCell.h"
//Models
#import "WUPSong.h"

@protocol WUPChoseSongViewControllerDelegate <NSObject>

-(void) pickedASong:(WUPSong*) song;

@end

@interface WUPChoseSongViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate>

@property(strong,nonatomic) id<WUPChoseSongViewControllerDelegate> delegate;
@property (strong,nonatomic) WUPSong* alreadySelectedSong;

@end
