//
//  RSSItemViewController.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSItemViewController.h"

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
    
    [_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_currentItem.link]]];
}

@end
