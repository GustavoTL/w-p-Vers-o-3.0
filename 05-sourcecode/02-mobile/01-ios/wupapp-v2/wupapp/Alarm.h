//
//  Alarm.h
//  wUpApp
//
//  Created by Adriano-Dcanm on 2/3/15.
//  Copyright (c) 2015 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Destination;

@interface Alarm : NSManagedObject

//@property (nonatomic, retain) NSNumber * actived;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * repeatsFor;
@property (nonatomic, retain) NSString * soundExtension;
@property (nonatomic, retain) NSString * soundFilename;
@property (nonatomic, retain) NSString * soundName;
@property (nonatomic, retain) NSNumber * timeToLeave;
@property (nonatomic, retain) NSDate * whenTime;
@property (nonatomic, retain) NSDate * dateSelected;
@property (nonatomic, retain) Destination *destination;

@end
