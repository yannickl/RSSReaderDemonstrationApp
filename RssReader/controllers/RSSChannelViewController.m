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
@property (strong, nonatomic) RSSConfigureCellBlock       configureCell;

@end

@implementation RSSChannelViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*RSSChannelEntity *currentChannel = [RSSChannelEntity rss_findFirstByAttribute:@"objectID" withValue:_channelID inContext:_mainObjectContext];
    self.title                       = currentChannel.title;*/
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"channel == %@", _channelID];
    
    _fetchedResultsController = [RSSFetchedResultsController rssFetchedResultControllerWithEntityName:[RSSItemEntity rss_name] inManagedObjectContext:_mainObjectContext withTableView:self.tableView andPredicate:predicate];
    
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
