//
//  WUPChoseSongViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPChoseSongViewController.h"

@interface WUPChoseSongViewController ()

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong,nonatomic) NSArray* arraySounds;

@end

@implementation WUPChoseSongViewController
long selectedRow;

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Choose Song Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI{
    //filling sounds array

    NSMutableArray* array = [[NSMutableArray alloc] init];
    [array addObject:[[WUPSong alloc]initWithName:@"Army" AndFileName:@"army_wake_up" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Bird" AndFileName:@"3d_bird_tone" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Butterfly" AndFileName:@"htc_butterfly_2013" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Clock Alarm" AndFileName:@"clock_alarm" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Elegant" AndFileName:@"elegant_ringtone" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Eletrônico" AndFileName:@"iphone_5s" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Iluminar" AndFileName:@"iphone_5s copy" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Nuclear" AndFileName:@"nuclear_alarm" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Padrão" AndFileName:@"v_i_p_ringtone" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Robótico" AndFileName:@"iphone_sms_message" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"SMS" AndFileName:@"sms" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Sweet" AndFileName:@"blackberry" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Tequila" AndFileName:@"tequila" AndExtension:@"mp3"]];
    [array addObject:[[WUPSong alloc]initWithName:@"Wolf" AndFileName:@"wolf" AndExtension:@"mp3"]];
   
    self.arraySounds = array;
    
    //Searching for alreadySelectedSong index on array
    selectedRow = [self.arraySounds indexOfObject:self.alreadySelectedSong];
    
}

#pragma mark - UITableViewDelegate methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString* identifier = @"WUPChoseSongTableViewCell";
    long index = [indexPath row];
    
    WUPChoseSongTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.nameLabel.text = [((WUPSong*)[self.arraySounds objectAtIndex:index]) name];
    
    if(index == selectedRow)
    {
        cell.checkMarkerImage.hidden = NO;
    }
    else
    {
        cell.checkMarkerImage.hidden = YES;
    }
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    long index = [indexPath row];
    WUPSong *song = [self.arraySounds objectAtIndex:index];
    self.alreadySelectedSong = song;
    
    NSString *soundFilePath = [[NSBundle mainBundle] pathForResource:song.fileName ofType: song.extension];
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath: soundFilePath];
    
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: fileURL error: &error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
    } else {
        [self.audioPlayer setVolume:1.0];
        [self.audioPlayer play];
    }
    selectedRow = index;
    [tableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.arraySounds count];
}

#pragma mark - Action methods

- (IBAction)touchUpNavBarCancelButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)touchUpNavBarOkButton:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate){
            [self.delegate pickedASong:self.alreadySelectedSong];
        }
    }];
}
@end
