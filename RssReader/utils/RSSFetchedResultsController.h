//
//  RSSFetchedResultsController.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ RSSConfigureCellBlock) (UITableViewCell *cell, NSIndexPath *indexPath);

@interface RSSFetchedResultsController : NSFetchedResultsController <NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) RSSConfigureCellBlock configureCell;

/**
 * @abstract Creates and retuns a fetched result controller with a given entity name, a managed object context, a table view and a predicate.
 */
+ (instancetype)rssFetchedResultControllerWithEntityName:(NSString *)entityName inManagedObjectContext:(NSManagedObjectContext *)managedObjectContext withTableView:(UITableView *)tableView andPredicate:(NSPredicate *)predicate;

@end
