//
//  RSSFetchedDataSourceProtocol.h
//  RssReader
//
//  Created by YannickL on 12/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSFetchedDataSource;

@protocol RSSFetchedDataSourceDelegate <NSObject>

/**
 * @abstract Asks the data source to configure a given cell in a particular location of the table view.
 */
- (void)fetchedDataSource:(RSSFetchedDataSource *)fetchedDataSource needsConfigureCell:(UITableViewCell *)cell withObject:(id)object;

@optional

/**
 * @abstract Asks the data source to verify that the given row is editable.
 */
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;

/**
 * @abstract Asks the data source to commit the insertion or deletion of a specified row in the receiver.
 */
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath;

@end
