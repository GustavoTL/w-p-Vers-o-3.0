//
//  WUPSong.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "WUPSong.h"

@implementation WUPSong

-(instancetype) initWithName:(NSString*) name AndFileName:(NSString*) filename AndExtension:(NSString*) extension
{
    self = [super init];
    if(self){
        self.name = name;
        self.fileName = filename;
        self.extension = extension;
    }
    return self;
}

-(BOOL)isEqual:(id)object
{
    if([object isKindOfClass:self.class])
    {
        WUPSong* songObj = (WUPSong*)object;
        if([self.name isEqualToString:songObj.name] && [self.fileName isEqualToString:songObj.fileName] && [self.extension isEqualToString:songObj.extension])
        {
            return YES;
        }else{
            return NO;
        }
    }else{
        return [super isEqual:object];
    }
}

@end
