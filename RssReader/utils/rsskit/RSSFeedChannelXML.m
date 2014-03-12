//
//  RSSFeedChannelXML.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFeedChannelXML.h"

@implementation RSSFeedChannelXML

- (id)init
{
    if ((self = [super init])) {
        _items = [NSMutableArray array];
    }
    return self;
}

#pragma mark - Utils

- (NSArray *)itemIDs
{
    NSMutableArray *itemIDs = [NSMutableArray array];
    
    for (RSSFeedItemXML *item in _items) {
        [itemIDs addObject:item.guid];
    }
    
    return itemIDs;
}

@end
