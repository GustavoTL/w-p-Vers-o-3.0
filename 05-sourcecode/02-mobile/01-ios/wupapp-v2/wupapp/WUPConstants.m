//
//  WUPConstants.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPConstants.h"

@implementation WUPConstants

+(WUPSong*) DEFAULT_SONG{
    static WUPSong* song ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        song = [[WUPSong alloc]initWithName:@"Padrão" AndFileName:@"v_i_p_ringtone" AndExtension:@"mp3"];
    });
    return song;
}

+(NSArray*) DEFAULT_REPEATDAYS{
    static NSArray* days;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        days = [[NSArray alloc] init];
    });
    return days;
}

+(NSString*) DEFAULT_SHARE_MSG{
    static NSString* message;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        message = @"Confira wÜp, um despertador inteligente que otimiza o seu tempo de acordo com o trânsito. Baixe agora em https://itunes.apple.com/us/app/wup/id905755858";
    });
    
    return message;
}

+(NSString*) OBJECT_ABSOLUTEURL_LOCALNOTIFICATION{
    static NSString* value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = @"sqliteObjectIDAbsoluteURL";
    });
    
    return value;
}

+(NSString*) OBJECT_LASTPATH_LOCALNOTIFICATION{
    static NSString* value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = @"sqliteObjectIDLastPath";
    });
    
    return value;
}

+(NSString*) OBJECT_MASTER_LOCALNOTIFICATION{
    static NSString* value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = @"masterNotification";
    });
    
    return value;
}

+(NSString*) OBJECT_TIMETOLEAVE_LOCALNOTIFICATION{
    static NSString* value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = @"timeToLeaveNotification";
    });
    
    return value;
}

+(NSString*) PREF_SETTING_FIRSTTIMELAUNCH{
    static NSString* value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = @"PREF_SETTING_FIRSTTIMELAUNCH";
    });
    
    return value;
}

+(int) NUMBER_REPEAT_ALARMS
{
    static int value;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        value = 4;
    });
    return value;
}

+(int) NUMBER_PADDING_ALARMS:(double) distance {
        
    int value;
    if(distance < 2.0) {
        value = 2;
    } else if(distance >= 2.0 && distance < 4.0){
        value = 4;
    } else if(distance >= 4.0 && distance < 6.0){
        value = 6;
    } else if(distance >= 6.0 && distance < 10.0){
        value = 12;
    } else {
        value = 20;
    }
    
    //return value * 20;
    return value * 60;

}

//Util

+(int) WEEKDAYNUMBER_FORWEEKDAY:(NSString*) weekday
{
    if([weekday isEqualToString:@"domingo"])
    {
        return 1;
    }
    else if([weekday isEqualToString:@"segunda-feira"])
    {
        return 2;
    }
    else if([weekday isEqualToString:@"terça-feira"])
    {
        return 3;
    }
    else if([weekday isEqualToString:@"quarta-feira"])
    {
        return 4;
    }
    else if([weekday isEqualToString:@"quinta-feira"])
    {
        return 5;
    }
    else if([weekday isEqualToString:@"sexta-feira"])
    {
        return 6;
    }
    else
    {
        return 7;
    }
}

@end
