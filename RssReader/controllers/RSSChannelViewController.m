//
//  RSSChannelViewController.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSChannelViewController.h"
#import "RSSFetchedResultsController.h"
#import "RSSItemViewController.h"

#import "RSSChannelEntity.h"
#import "RSSItemEntity.h"
#import "NSManagedObject+RssReader.h"

// Constants
static NSString * const kRSSFeedDisplayItemVCSegueName = @"RSSFeedDisplayItemSegue";

static NSString * const kRSSFeedCellName = @"RSSItemCell";

@interface RSSChannelViewController ()
@property (strong, nonatomic) RSSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest              *fetchRequest;
@property (strong, nonatomic) RSSConfigureCellBlock       configureCell;

@end

@implementation RSSChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*RSSChannelEntity *currentChannel = [RSSChannelEntity rss_findFirstByAttribute:@"objectID" withValue:_channelID inContext:_mainObjectContext];
    self.title                       = currentChannel.title;*/

    // Setup the fetched result controller
    _fetchedResultsController = [RSSFetchedResultsController rssFetchedResultControllerWithRequest:self.fetchRequest inManagedObjectContext:self.mainObjectContext withTableView:self.tableView cacheName:kRSSFeedCellName];
    
    __weak typeof(self) weakSelf = self;
    self.configureCell           = ^ (UITableViewCell *cell, NSIndexPath *indexPath) {
        RSSItemEntity *item       = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text       = [item title];
    };
    _fetchedResultsController.configureCell = _configureCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kRSSFeedDisplayItemVCSegueName]) {
        RSSItemViewController *vc = [segue destinationViewController];
        vc.mainObjectContext      = _mainObjectContext;
    }
}

#pragma mark - Properties

- (NSFetchRequest *)fetchRequest
{
    if (_fetchRequest) {
        return _fetchRequest;
    }
    
    _fetchRequest               = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[RSSItemEntity rss_name] inManagedObjectContext:_mainObjectContext];
    [_fetchRequest setEntity:entity];
    
    // Set the predicate
    NSPredicate *currentChannelPredicate = [NSPredicate predicateWithFormat:@"channel == %@", _channelID];
    [_fetchRequest setPredicate:currentChannelPredicate];
    
    // Set the batch size to a suitable number.
    [_fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    NSArray *sortDescriptors         = @[sortDescriptor];
    
    [_fetchRequest setSortDescriptors:sortDescriptors];
    
    return _fetchRequest;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRSSFeedCellName forIndexPath:indexPath];
    _configureCell(cell, indexPath);
    return cell;
}

@end
