//
//  RSSFeedsViewController.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFeedsViewController.h"
#import "RSSFetchedResultsController.h"

#import "RSSAddFeedViewController.h"
#import "RSSChannelViewController.h"

#import "RSSChannelEntity.h"
#import "NSManagedObject+RssReader.h"

// Constants
static NSString * const kRSSFeedDisplayAddFeedVCSegueName = @"RSSFeedDisplayAddNewFeedSegue";
static NSString * const kRSSFeedDisplayEntriesVCSegueName = @"RSSFeedDisplayEntriesSegue";

static NSString * const kRSSFeedCellName = @"RSSChannelCell";

@interface RSSFeedsViewController ()
@property (strong, nonatomic) RSSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest              *fetchRequest;
@property (strong, nonatomic) RSSConfigureCellBlock       configureCell;

@end

@implementation RSSFeedsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    // Setup the fetched result controller
    _fetchedResultsController = [RSSFetchedResultsController rssFetchedResultControllerWithRequest:self.fetchRequest inManagedObjectContext:self.mainObjectContext withTableView:self.tableView cacheName:kRSSFeedCellName];
    
    __weak typeof(self) weakSelf = self;
    self.configureCell           = ^ (UITableViewCell *cell, NSIndexPath *indexPath) {
        RSSChannelEntity *channel = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text       = [channel title];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@/%lu unread entries", @"Displayed the number of entries unread"), channel.unreadItems, (unsigned long)[channel.items count]];
    };
    _fetchedResultsController.configureCell = _configureCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kRSSFeedDisplayAddFeedVCSegueName]) {
        RSSAddFeedViewController *vc = [segue destinationViewController];
        vc.mainObjectContext         = _mainObjectContext;
    }
    else if ([[segue identifier] isEqualToString:kRSSFeedDisplayEntriesVCSegueName]) {
        NSIndexPath *indexPath   = [self.tableView indexPathForSelectedRow];
        NSManagedObject *channel = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        RSSChannelViewController *vc = [segue destinationViewController];
        vc.mainObjectContext         = _mainObjectContext;
        vc.channelID                 = channel.objectID;
    }
}

#pragma mark - Properties

- (NSFetchRequest *)fetchRequest
{
    if (_fetchRequest) {
        return _fetchRequest;
    }
    
    _fetchRequest               = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:[RSSChannelEntity rss_name] inManagedObjectContext:_mainObjectContext];
    [_fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [_fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
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

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
