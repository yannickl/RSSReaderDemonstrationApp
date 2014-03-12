//
//  RSSFeedItemXML.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFeedItemXML.h"

@implementation RSSFeedItemXML

- (NSString *)guid
{
    // Returns the link as guid if it does not exists
    return _guid ?: _link;
}

@end
