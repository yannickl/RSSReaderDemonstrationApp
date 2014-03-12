//
//  RSSItemViewController.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSItemViewController.h"

#import "RSSChannelEntity.h"
#import "RSSItemEntity.h"
#import "NSManagedObject+RssReader.h"

@interface RSSItemViewController ()
@property (nonatomic, strong) RSSItemEntity *currentItem;

@end

@implementation RSSItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentItem = [RSSItemEntity rss_findByID:_itemID inContext:_mainObjectContext];
    self.title   = _currentItem.title;
    
    if (![_currentItem.markAsRead boolValue]) {
        [_mainObjectContext performBlock:^{
            _currentItem.markAsRead          = @(YES);
            _currentItem.channel.unreadItems = @([_currentItem.channel.unreadItems integerValue] - 1);
            
            NSError *error;
            if (![_mainObjectContext save:&error]) {
                NSLog(@"error: %@", error);
            }
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_currentItem.link]]];
}

@end
