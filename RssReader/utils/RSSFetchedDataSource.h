//
//  RSSFetchedDataSource.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSFetchedDataSourceProtocol.h"

@interface RSSFetchedDataSource : NSObject <NSFetchedResultsControllerDelegate, UITableViewDataSource>
@property (nonatomic, weak) id<RSSFetchedDataSourceDelegate>       delegate;
@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, getter = isPaused) BOOL                      paused;

#pragma mark - Contructors / Initializers

/**
 * @abstract Creates and retuns a fetched result data source with a given fetched result controller, a table view and a reuseIdentifier.
 */
- (id)initWithFetchedResultViewController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier;

@end
