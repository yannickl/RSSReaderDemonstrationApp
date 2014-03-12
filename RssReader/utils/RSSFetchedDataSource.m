//
//  RSSFetchedDataSource.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFetchedDataSource.h"

@interface RSSFetchedDataSource ()
@property (nonatomic, strong) UITableView                 *tableView;
@property (nonatomic, strong) NSString                    *reuseIdentifier;
@property (nonatomic, strong) NSFetchedResultsController  *fetchedResultsController;
@end

@implementation RSSFetchedDataSource

- (id)initWithFetchedResultViewController:(NSFetchedResultsController *)fetchedResultsController tableView:(UITableView *)tableView reuseIdentifier:(NSString *)reuseIdentifier
{
    NSParameterAssert(fetchedResultsController);
    NSParameterAssert(tableView);
    NSParameterAssert(reuseIdentifier);
    
    if ((self = [super init])) {
        _fetchedResultsController = fetchedResultsController;
        _tableView                = tableView;
        _reuseIdentifier          = reuseIdentifier;
        
        _fetchedResultsController.delegate = self;
        _tableView.dataSource              = self;
    }
    
    return self;
}

#pragma mark - Properties

- (void)setPaused:(BOOL)paused
{
    _paused = paused;
    
    if (paused) {
        self.fetchedResultsController.delegate = nil;
    }
    else {
        self.fetchedResultsController.delegate = self;
        
        NSError *error;
        if (![self.fetchedResultsController performFetch:NULL]) {
            NSLog(@"error: %@", error);
        }
        
        [self.tableView reloadData];
    }
}

#pragma mark - NSFetchedResultsController Delegate Methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    switch(type) {
        case NSFetchedResultsChangeInsert: {
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
            
        case NSFetchedResultsChangeDelete: {
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
            
        case NSFetchedResultsChangeUpdate: {
            if (_delegate) {
                [_delegate fetchedDataSource:self needsConfigureCell:[_tableView cellForRowAtIndexPath:indexPath] withObject:[controller objectAtIndexPath:indexPath]];
            }
        } break;
            
        case NSFetchedResultsChangeMove: {
            [_tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [_tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        } break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [_tableView endUpdates];
}

#pragma mark - UITableView Data Source Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_fetchedResultsController.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = _fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_reuseIdentifier forIndexPath:indexPath];
    
    if (_delegate) {
        [_delegate fetchedDataSource:self needsConfigureCell:cell withObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:canEditRowAtIndexPath:)]) {
        return [_delegate tableView:tableView canEditRowAtIndexPath:indexPath];
    }
    else {
        return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegate && [_delegate respondsToSelector:@selector(tableView:commitEditingStyle:forRowAtIndexPath:)]) {
        [_delegate tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    }
}

@end
