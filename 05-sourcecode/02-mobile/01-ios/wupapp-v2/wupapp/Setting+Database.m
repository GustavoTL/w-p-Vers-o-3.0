//
//  Setting+Database.m
//  wUpApp
//
//  Created by Paulo Miguel Almeida on 7/5/14.
//  Copyright (c) 2014 Paulo Miguel Almeida. All rights reserved.
//

#import "Setting+Database.h"

@implementation Setting (Database)

#pragma mark - Crud methods

+ (id)insertNewObjectInContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass ([self class])inManagedObjectContext:context];
}

+ (NSArray*) loadAll:(NSManagedObjectContext*) context
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc]init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass ([self class]) inManagedObjectContext:context];
    
    [fetchRequest setEntity:entity];
    NSError* error;
    
    NSArray* fetchedRecords = [context executeFetchRequest:fetchRequest error:&error];
    if(!error)
    {
        return fetchedRecords;
    }else{
        return nil;
    }
}

+ (void) deleteAll:(NSManagedObjectContext*) context
{
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:NSStringFromClass ([self class]) inManagedObjectContext:context]];
    [fetchRequest setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError * error = nil;
    NSArray * fetchedRecords = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject * obj in fetchedRecords) {
        [context deleteObject:obj];
    }
    NSError *saveError = nil;
    if (![context save:&saveError]) {
        NSLog(@"Whoops, couldn't delete: %@", [error localizedDescription]);
    }
}

+ (id) fetchFirst:(NSManagedObjectContext*) context{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass ([self class]) inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setFetchLimit:1];
    
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];
    
    NSObject *result = nil;
    
    if ([fetchResults count]>0){
        result = [fetchResults objectAtIndex:0];
    }
    return result;
}

+ (id) fetchFirst:(NSManagedObjectContext*) context WithName:(NSString*) name{
    NSEntityDescription *entity = [NSEntityDescription entityForName:NSStringFromClass ([self class]) inManagedObjectContext:context];
    
    NSError *error;
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:
                              @"name = %@", name];
    
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:1];
    
    NSArray *fetchResults = [context executeFetchRequest:request error:&error];
    
    NSObject *result = nil;
    
    if ([fetchResults count]>0){
        result = [fetchResults objectAtIndex:0];
    }
    return result;
}

@end
