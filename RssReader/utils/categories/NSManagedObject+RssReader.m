//
//  NSManagedObject+RssReader.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "NSManagedObject+RssReader.h"

@implementation NSManagedObject (RssReader)

+ (NSString *)rss_name
{
    return NSStringFromClass([self class]);
}

+ (instancetype)rss_insertNewObjectIntoContext:(NSManagedObjectContext *)context
{
    return [NSEntityDescription insertNewObjectForEntityForName:[self rss_name] inManagedObjectContext:context];
}

#pragma mark - Find by ID

+ (instancetype)rss_findByID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context {
    NSError *error;
    
    id managedObject = [context existingObjectWithID:objectID error:&error];
    if (error) {
        NSLog(@"error: %@", error);
        return nil;
    }
    
    return managedObject;
}

#pragma mark - Find by Attribute/Value pair

+ (instancetype)rss_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self rss_requestAllByAttribute:attribute withValue:searchValue inContext:context];
    
    return [self rss_executeFetchRequestAndReturnFirstObject:request inContext:context];
}

+ (NSArray *)rss_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [self rss_requestAllByAttribute:attribute withValue:searchValue inContext:context];
    
    return [self rss_executeFetchRequest:request inContext:context];
}

#pragma mark - Find by Fetch Requests

+ (NSArray *)rss_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    __block NSArray *results = nil;
    
    [context performBlockAndWait:^{
        NSError *error = nil;
        
        results = [context executeFetchRequest:request error:&error];
        if (results == nil) {
            NSLog(@"error: %@", error);
        }
    }];
    
    return results;
}

+ (instancetype)rss_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context
{
    [request setFetchLimit:1];
    
    NSArray *results = [self rss_executeFetchRequest:request inContext:context];
    if ([results count] == 0) {
        return nil;
    }
    return [results firstObject];
}

#pragma mark - Private Methods

+ (NSEntityDescription *)rss_entityInManagedObjectContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription entityForName:[self rss_name] inManagedObjectContext:context];
}

+ (NSFetchRequest *)rss_requestAllByAttribute:(NSString *)property withValue:(id)value inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [self rss_entityInManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", property, value]];
    
    return request;
}

@end
