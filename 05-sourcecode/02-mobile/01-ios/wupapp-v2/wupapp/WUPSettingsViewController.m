//
//  WUPSettingsViewController.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPSettingsViewController.h"

@interface WUPSettingsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *rateUsLabel;
@property (weak, nonatomic) IBOutlet UILabel *recommendToFriendsLabel;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;

@property (strong, nonatomic) MPMoviePlayerController *moviePlayer;
@end

@implementation WUPSettingsViewController

#pragma mark - UIViewController lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
    
    //Google Analytics SendScreen
    id tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"About App Screen"];
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
}

-(void) setupUI
{
    //Changing Fonts
    self.rateUsLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.recommendToFriendsLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
    self.instructionsLabel.font = [UIFont fontWithName:kProximaNovaFontNameRegular size:16.0f];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //Changing TabBar Appearance
    UITabBar *tabBar = self.tabBarController.tabBar;
    if ([tabBar respondsToSelector:@selector(setBackgroundImage:)])
    {
        // set it just for this instance
        [tabBar setBackgroundImage:[UIImage imageNamed:NSLocalizedString(@"tabbar_about_image_name", "nome da imagem sobre tabbar")]];//@"navbar_about_image"
    }
}

#pragma mark - Action methods
- (IBAction)touchUpRateAppleStore:(id)sender {
    NSString *str = @"itms-apps://itunes.apple.com/app/id905755858";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (IBAction)touchUpListRecommendToFriendsView:(id)sender {
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"indicar_wup_para_amigos", @"texto nome")
                                                            delegate:self cancelButtonTitle:@"Cancel"
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"SMS", @"Email",@"WhatsApp", nil];
    
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [popupQuery showInView:self.view];
}
- (IBAction)touchUpTimeToLeaveView:(id)sender {
    [self performSegueWithIdentifier:@"SettingsToSetTimeToLeaveSegue" sender:self];
}

-(IBAction)playMovie:(id)sender
{
    NSURL * url = [[NSBundle mainBundle] URLForResource:NSLocalizedString(@"nome_video", nil) withExtension:@"m4v"];
    _moviePlayer =  [[MPMoviePlayerController alloc]
                     initWithContentURL:url];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:_moviePlayer];
    
    _moviePlayer.controlStyle = MPMovieControlStyleDefault;
    _moviePlayer.shouldAutoplay = YES;
    [self.view addSubview:_moviePlayer.view];
    [_moviePlayer setFullscreen:YES animated:YES];
}

#pragma mark - UIActionSheetDelegate methods
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        if(![MFMessageComposeViewController canSendText]) {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            return;
        }
        
        NSString *message = [WUPConstants DEFAULT_SHARE_MSG];
        
        MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
        messageController.messageComposeDelegate = self;
        [messageController setBody:message];
        
        [self presentViewController:messageController animated:YES completion:nil];
    }else if(buttonIndex == 1){
        NSString *emailTitle = @"wÜp App";
        NSString *messageBody = [WUPConstants DEFAULT_SHARE_MSG];;

        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:messageBody isHTML:NO];
        
        [self presentViewController:mc animated:YES completion:NULL];
    }else if(buttonIndex == 2){
        
        NSString *unescaped = [WUPConstants DEFAULT_SHARE_MSG];
        NSString *charactersToEscape = @"!*'();:@&=+$,/?%#[]\" ";
        NSCharacterSet *allowedCharacters = [[NSCharacterSet characterSetWithCharactersInString:charactersToEscape] invertedSet];
        NSString *encodedString = [unescaped stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacters];
        
        NSURL *whatsappURL = [NSURL URLWithString:[NSString stringWithFormat:@"whatsapp://send?text=%@",encodedString ]];
        if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
            [[UIApplication sharedApplication] openURL: whatsappURL];
        }
    }
    
}

#pragma mark - MFMessageComposeViewControllerDelegate methods
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
   
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - MFMailComposeViewControllerDelegate methods
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - MediaPlayer callback methods

- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    MPMoviePlayerController *player = [notification object];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self
     name:MPMoviePlayerPlaybackDidFinishNotification
     object:player];
    
    if ([player
         respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}

@end
