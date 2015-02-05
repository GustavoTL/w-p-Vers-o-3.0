//
//  WUPSong.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 6/30/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WUPSong : NSObject

@property(strong,nonatomic) NSString* name;
@property(strong,nonatomic) NSString* fileName;
@property(strong,nonatomic) NSString* extension;

-(instancetype) initWithName:(NSString*) name AndFileName:(NSString*) filename AndExtension:(NSString*) extension;

@end
