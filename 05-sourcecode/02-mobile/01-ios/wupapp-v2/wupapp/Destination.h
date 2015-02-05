//
//  Destination.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 8/12/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Alarm;

@interface Destination : NSManagedObject

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *alarm;
@end

@interface Destination (CoreDataGeneratedAccessors)

- (void)addAlarmObject:(Alarm *)value;
- (void)removeAlarmObject:(Alarm *)value;
- (void)addAlarm:(NSSet *)values;
- (void)removeAlarm:(NSSet *)values;

@end
