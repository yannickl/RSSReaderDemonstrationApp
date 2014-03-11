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
#import "RSSChannelEntity.h"
#import "NSManagedObject+RssReader.h"

// Constants
static NSString * const kRSSFeedDisplayAddFeedVCSegueName = @"RSSFeedDisplayAddNewFeedSegue";
static NSString * const kRSSFeedDisplayEntriesVCSegueName = @"RSSFeedDisplayEntriesSegue";

static NSString * const kRSSFeedCellName = @"RSSFeedCell";

static NSString * const kRSSFeedChannelObjectName = @"Channel";

@interface RSSFeedsViewController ()
@property (strong, nonatomic) RSSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) RSSConfigureCellBlock       configureCell;

@end

@implementation RSSFeedsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
    _fetchedResultsController = [RSSFetchedResultsController rssFetchedResultControllerWithEntityName:[RSSChannelEntity rss_name] inManagedObjectContext:_mainObjectContext withTableView:self.tableView];
    
    __weak typeof(self) weakSelf = self;
    self.configureCell           = ^ (UITableViewCell *cell, NSIndexPath *indexPath) {
        RSSChannelEntity *channel = [weakSelf.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text       = [channel title];
        cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%lu entries", @"Displayed the number of entries"), (unsigned long)[channel.items count]];
    };
    _fetchedResultsController.configureCell = _configureCell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:kRSSFeedDisplayAddFeedVCSegueName]) {
        RSSAddFeedViewController *vc = [segue destinationViewController];
        vc.mainObjectContext         = _mainObjectContext;
    }
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
