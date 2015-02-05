//
//  Alarm+Database.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/2/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "Alarm.h"

@interface Alarm (Database)

#pragma mark - Crud methods
+ (id)insertNewObjectInContext:(NSManagedObjectContext *)context;
+ (NSArray*) loadAll:(NSManagedObjectContext*) context;
+ (void) deleteAll:(NSManagedObjectContext*) context;
+ (id) fetchFirst:(NSManagedObjectContext*) context;
+ (NSArray*) loadAllOneTimeOnly:(NSManagedObjectContext*) context;

@end
