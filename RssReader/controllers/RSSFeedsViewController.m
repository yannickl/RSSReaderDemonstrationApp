//
//  RSSFeedsViewController.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFeedsViewController.h"
#import "RSSFetchedDataSource.h"

#import "RSSAddFeedViewController.h"
#import "RSSChannelViewController.h"

#import "RSSChannelEntity.h"
#import "NSManagedObject+RssReader.h"

// Constants
static NSString * const kRSSFeedDisplayAddFeedVCSegueName = @"RSSFeedDisplayAddNewFeedSegue";
static NSString * const kRSSFeedDisplayEntriesVCSegueName = @"RSSFeedDisplayEntriesSegue";

static NSString * const kRSSFeedCellName = @"RSSChannelCell";

@interface RSSFeedsViewController ()
@property (strong, nonatomic) RSSFetchedDataSource       *fetchedDataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest             *fetchRequest;

@end

@implementation RSSFeedsViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    
    // Setup the fetched result controller
    _fetchedResultsController   = [RSSChannelEntity rss_fetchedResultsControllerWithRequest:self.fetchRequest inContext:_mainObjectContext];
    _fetchedDataSource          = [[RSSFetchedDataSource alloc] initWithFetchedResultViewController:_fetchedResultsController tableView:self.tableView reuseIdentifier:kRSSFeedCellName];
    _fetchedDataSource.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _fetchedDataSource.paused = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _fetchedDataSource.paused = YES;
}

#pragma mark - Storyboard

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
    NSEntityDescription *entity = [RSSChannelEntity rss_entityInManagedObjectContext:_mainObjectContext];
    [_fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [_fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:NO];
    NSArray *sortDescriptors         = @[sortDescriptor];
    
    [_fetchRequest setSortDescriptors:sortDescriptors];
    
    return _fetchRequest;
}

#pragma mark - RSSFetchedResultsDataSource Delegate Methods

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = [_fetchedResultsController managedObjectContext];
        [context deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)fetchedDataSource:(RSSFetchedDataSource *)fetchedDataSource needsConfigureCell:(UITableViewCell *)cell withObject:(RSSChannelEntity *)channel
{
    cell.textLabel.text       = [channel title];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%@/%lu unread entries", @"Displayed the number of entries unread"), channel.unreadItems, (unsigned long)[channel.items count]];
}

@end
