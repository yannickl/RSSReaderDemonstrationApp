//
//  RSSChannelViewController.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSChannelViewController.h"
#import "RSSItemViewController.h"

#import "RSSFetchedDataSource.h"

#import "RSSRequestFeedOperation.h"

#import "RSSChannelEntity.h"
#import "RSSChannelEntity+XML.h"
#import "RSSItemEntity.h"
#import "NSManagedObject+RssReader.h"

// Constants
static NSString * const kRSSFeedDisplayItemVCSegueName = @"RSSFeedDisplayItemSegue";

static NSString * const kRSSFeedCellName = @"RSSItemCell";

@interface RSSChannelViewController ()
@property (strong, nonatomic) NSOperationQueue  *backgroundQueue;
@property (strong, nonatomic) RSSChannelEntity  *currentChannel;

@property (strong, nonatomic) RSSFetchedDataSource       *fetchedDataSource;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSFetchRequest             *fetchRequest;

@end

@implementation RSSChannelViewController

#pragma mark - View Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Retrieve the current channel
    _currentChannel = [RSSChannelEntity rss_findByID:_channelID inContext:_mainObjectContext];
    self.title      = _currentChannel.title;

    // Setup the fetched result controller
    _fetchedResultsController   = [RSSItemEntity rss_fetchedResultsControllerWithRequest:self.fetchRequest inContext:_mainObjectContext];
    _fetchedDataSource          = [[RSSFetchedDataSource alloc] initWithFetchedResultViewController:self.fetchedResultsController tableView:self.tableView reuseIdentifier:kRSSFeedCellName];
    _fetchedDataSource.delegate = self;
    
    // Create the background queue to update the feed
    _backgroundQueue                             = [[NSOperationQueue alloc] init];
    _backgroundQueue.maxConcurrentOperationCount = 1;
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
    if ([[segue identifier] isEqualToString:kRSSFeedDisplayItemVCSegueName]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSManagedObject *item  = [[self fetchedResultsController] objectAtIndexPath:indexPath];
        
        RSSItemViewController *vc = [segue destinationViewController];
        vc.mainObjectContext      = _mainObjectContext;
        vc.itemID                 = item.objectID;
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

#pragma mark - IBAction

- (IBAction)refreshAction:(id)sender
{
    _refrechButtonItem.enabled = NO;
    
    RSSRequestFeedOperation *requestFeedOperation = [[RSSRequestFeedOperation alloc] initWithFeedURL:[_currentChannel xml_sourceURL]];
    
    __weak typeof(self) weakSelf = self;
    [requestFeedOperation setFeedCompletionBlock:^ (NSError *error, RSSFeedChannelXML *channelXML) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        weakSelf.refrechButtonItem.enabled = YES;
        
        if (channelXML) {
            [RSSChannelEntity xml_insertOrUpdateChannelFromXML:channelXML inContext:weakSelf.mainObjectContext completionBlock:NULL];
        }
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_backgroundQueue addOperation:requestFeedOperation];
}

#pragma mark - RSSFetchedResultsDataSource Delegate Methods

- (void)fetchedDataSource:(RSSFetchedDataSource *)fetchedDataSource needsConfigureCell:(UITableViewCell *)cell withObject:(RSSItemEntity *)item
{
    cell.textLabel.text       = [item title];
    cell.detailTextLabel.text = ([item.markAsRead boolValue]) ? NSLocalizedString(@"Read", @"Message displayed when the item is already read") : NSLocalizedString(@"Unread", @"Message displayed when the item is not read yet");
}

@end
