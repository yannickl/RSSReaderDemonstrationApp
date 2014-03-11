//
//  RSSFeedXMLParser.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSFeedChannelXML;

@interface RSSFeedXMLParser : NSObject <NSXMLParserDelegate>
@property (nonatomic, strong) RSSFeedChannelXML *channel;

#pragma mark - Initializers / Constructors

- (id)initWithData:(NSData *)data;

#pragma mark - Public Methods

- (BOOL)parse;

@end
