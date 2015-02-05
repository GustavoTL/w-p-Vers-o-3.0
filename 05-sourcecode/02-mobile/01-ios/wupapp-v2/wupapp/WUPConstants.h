//
//  WUPConstants.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

//Models
#import "WUPSong.h"

@interface WUPConstants : NSObject

+(WUPSong*) DEFAULT_SONG;
+(NSArray*) DEFAULT_REPEATDAYS;
+(NSString*) DEFAULT_SHARE_MSG;

+(NSString*) OBJECT_ABSOLUTEURL_LOCALNOTIFICATION;
+(NSString*) OBJECT_LASTPATH_LOCALNOTIFICATION;
+(NSString*) OBJECT_MASTER_LOCALNOTIFICATION;
+(NSString*) OBJECT_TIMETOLEAVE_LOCALNOTIFICATION;

+(NSString*) PREF_SETTING_FIRSTTIMELAUNCH;

+(int) NUMBER_REPEAT_ALARMS;
+(int) NUMBER_PADDING_ALARMS:(double) distance;

//Util
+(int) WEEKDAYNUMBER_FORWEEKDAY:(NSString*) weekday;

@end
