//
//  NSManagedObject+RssReader.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (RssReader)

/**
 * @abstract Returns the current entity name.
 */
+ (NSString *)rss_name;

/**
 * @abstract Creates and returns a new instance of the entity in a given context.
 */
+ (instancetype)rss_insertNewObjectIntoContext:(NSManagedObjectContext *)context;

/**
 * @abstract Creates and returns the entity in a given context. 
 */
+ (NSEntityDescription *)rss_entityInManagedObjectContext:(NSManagedObjectContext *)context;

/**
 * @abstract Creates and returns a fetched results controller with a given request from a given context
 */
+ (NSFetchedResultsController *)rss_fetchedResultsControllerWithRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

#pragma mark - Find by ID

/**
 * @abstract Returns the entities corresponding to a given object ID.
 */
+ (instancetype)rss_findByID:(NSManagedObjectID *)objectID inContext:(NSManagedObjectContext *)context;

#pragma mark - Find by Attribute/Value pair

/**
 * @abstract Returns the entities which match with the given attribute/value pair.
 */
+ (NSArray *)rss_findByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;

/**
 * @abstract Returns the first entity which match with the given attribute/value pair.
 */
+ (instancetype)rss_findFirstByAttribute:(NSString *)attribute withValue:(id)searchValue inContext:(NSManagedObjectContext *)context;

#pragma mark - Find by Fetch Requests

/**
 * @abstract Execute a given fetch request and returns the entity founds.
 */
+ (NSArray *)rss_executeFetchRequest:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

/**
 * @abstract Execute a given fetch request and returns the first entity found.
 */
+ (instancetype)rss_executeFetchRequestAndReturnFirstObject:(NSFetchRequest *)request inContext:(NSManagedObjectContext *)context;

@end
