//
//  RSSFeedXMLParserTests.m
//  RssReader
//
//  Created by YannickL on 14/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RSSFeedXMLParser.h"
#import "RSSFeedChannelXML.h"

@interface RSSFeedXMLParserTests : XCTestCase

@end

@implementation RSSFeedXMLParserTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParseBBCNewsRss
{
    NSBundle *testBundle = [NSBundle bundleForClass:[self class]];
    NSURL *rssURL        = [testBundle URLForResource:@"rssFromBBCNews" withExtension:@"xml"];
    NSData *rssData      = [NSData dataWithContentsOfURL:rssURL];
    
    RSSFeedXMLParser *parser = [[RSSFeedXMLParser alloc] initWithData:rssData];
    BOOL parsed              = [parser parse];
    
    XCTAssertTrue(parsed, @"The RSS should be parsed with success");
    
    RSSFeedChannelXML *channel = parser.channel;
    XCTAssertNotNil(channel, @"A channel should be not nil");
    XCTAssertEqualObjects(channel.title, @"BBC News - Home", @"The BBC News channel title are not equals");
    XCTAssertEqualObjects(channel.link, @"http://www.bbc.co.uk/news/#sa-ns_mchannel=rss&ns_source=PublicRSS20-sa");
    XCTAssertEqualObjects(channel.summary, @"The latest stories from the Home section of the BBC News web site.");
    XCTAssertEqual(channel.items.count, 68, @"The channel should have 68 items");
    
    RSSFeedItemXML *item = [channel.items objectAtIndex:5];
    XCTAssertEqualObjects(item.title, @"Site ordered to remove Sarkozy tapes");
    XCTAssertEqualObjects(item.summary, @"A French court orders a news website to remove files of secretly taped conversations involving Nicolas Sarkozy during his time as president.");
    XCTAssertEqualObjects(item.guid, @"http://www.bbc.co.uk/news/world-europe-26578085");
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.locale           = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    dateFormatter.dateFormat       = @"E, dd MMM y HH:mm:ss zz";
    NSDate *date                   = [dateFormatter dateFromString:@"Fri, 14 Mar 2014 14:43:05 GMT"];
    XCTAssertEqualObjects(item.pubDate, date);
}

@end
