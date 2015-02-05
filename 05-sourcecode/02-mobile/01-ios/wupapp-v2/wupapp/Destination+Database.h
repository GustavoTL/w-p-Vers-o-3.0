//
//  Destination+Database.h
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/1/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "Destination.h"

@interface Destination (Database)

#pragma mark - Crud methods
+ (id)insertNewObjectInContext:(NSManagedObjectContext *)context;
+ (NSArray*) loadAll:(NSManagedObjectContext*) context;
+ (void) deleteAll:(NSManagedObjectContext*) context;
+ (id) fetchFirst:(NSManagedObjectContext*) context;

@end
