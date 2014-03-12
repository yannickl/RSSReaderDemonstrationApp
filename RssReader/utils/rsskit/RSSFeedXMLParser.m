//
//  RSSFeedXMLParser.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSFeedXMLParser.h"
#import "RSSFeedChannelXML.h"

static NSString * const kRSSFeedXMLChannelElementName = @"channel";
static NSString * const kRSSFeedXMLItemElementName    = @"item";

@interface RSSFeedXMLParser ();
@property (nonatomic, strong) id              currentElement;
@property (nonatomic, strong) id              channelImage;
@property (nonatomic, strong) NSMutableString *currentElementString;
@property (nonatomic, strong) NSXMLParser     *parser;
@end

@implementation RSSFeedXMLParser

- (id)initWithData:(NSData *)data
{
    if ((self = [super init])) {
        _parser          = [[NSXMLParser alloc] initWithData:data];
        _parser.delegate = self;
    }
    return self;
}

#pragma mark - Public Methods

- (BOOL)parse
{
    return [_parser parse];
}

#pragma mark - NSXMLParserDelegate  Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    
    if ([elementName isEqualToString:kRSSFeedXMLChannelElementName]) {
        RSSFeedChannelXML *channel = [[RSSFeedChannelXML alloc] init];
        self.channel               = channel;
        self.currentElement        = channel;
        return;
        
    }
    
    else if ([elementName isEqualToString:kRSSFeedXMLItemElementName]) {
        RSSFeedItemXML *item = [[RSSFeedItemXML alloc] init];
        [_channel.items addObject:item];
        self.currentElement = item;
        
        return;
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (_currentElementString == nil) {
        self.currentElementString = [[NSMutableString alloc] init];
    }
    
    [_currentElementString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    
    NSString *trimmingString = [_currentElementString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Special case with the description field
    if ([elementName isEqualToString:@"description"]) {
        [_currentElement setValue:trimmingString forKey:@"summary"];
    }
    // Special case with the thumbnail
    else if ([elementName isEqualToString:@"url"] && [_currentElement isKindOfClass:[RSSFeedChannelXML class]]) {
        NSData *originalImageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:trimmingString]];
        NSData *pngImageData      = UIImagePNGRepresentation([[UIImage alloc] initWithData:originalImageData]);
        [_currentElement setValue:pngImageData forKey:@"thumbnail"];
    }
    // Special case with the date
    else if ([elementName isEqualToString:@"pubDate"] && [_currentElement isKindOfClass:[RSSFeedItemXML class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale           = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        dateFormatter.dateFormat       = @"E, dd MMM y HH:mm:ss zz";
        NSDate *date                   = [dateFormatter dateFromString:trimmingString];
        
        [_currentElement setValue:date forKey:@"pubDate"];
    }
    else {
        SEL selectorName = NSSelectorFromString(elementName);
        if ([_currentElement respondsToSelector:selectorName]) {
            [_currentElement setValue:trimmingString forKey:elementName];
        }
    }
    
    self.currentElementString = nil;
}

@end
