//
//  RSSFeedChannelXML.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RSSFeedItemXML.h"

@interface RSSFeedChannelXML : NSObject
@property (nonatomic, strong) NSURL          *sourceURL;
@property (nonatomic, strong) NSString       *summary;
@property (nonatomic, strong) NSString       *title;
@property (nonatomic, strong) NSString       *link;
@property (nonatomic, strong) NSData         *thumbnail;
@property (nonatomic, strong) NSMutableArray *items;

#pragma mark - Utils

/**
 * @abstract Returns an array which contains all the guid of the items.
 */
- (NSArray *)itemIDs;

@end
