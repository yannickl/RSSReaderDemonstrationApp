//
//  RSSChannelEntity+XML.h
//  RssReader
//
//  Created by YannickL on 12/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSChannelEntity.h"

@class RSSFeedChannelXML;

@interface RSSChannelEntity (XML)

/**
 * @abstract Returns the source URL.
 */
- (NSURL *)xml_sourceURL;

/**
 * @abstract Inserts or updates the channel/item entities using a given channel XML object from a given context.
 */
+ (void)xml_insertOrUpdateChannelFromXML:(RSSFeedChannelXML *)channelXML inContext:(NSManagedObjectContext *)context completionBlock:(void (^) ())completionBlock;

@end
