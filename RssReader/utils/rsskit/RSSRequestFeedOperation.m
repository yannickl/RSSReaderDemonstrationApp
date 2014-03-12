//
//  RSSRequestFeedOperation.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSRequestFeedOperation.h"
#import "RSSFeedXMLParser.h"
#import "RSSFeedChannelXML.h"

@interface RSSRequestFeedOperation ()

/** Invoke the completion block in the main thread with the given informations. */
- (void)invokeCompletionBlockWithChannelXML:(RSSFeedChannelXML *)channelXML error:(NSError *)error;

@end

@implementation RSSRequestFeedOperation

- (id)initWithFeedURL:(NSURL *)feedURL
{
    if ((self = [super init])) {
        _feedURL = feedURL;
    }
    return self;
}

+ (instancetype)requestFeedOperationWithURL:(NSURL *)feedURL
{
    return [[self alloc] initWithFeedURL:feedURL];
}

#pragma mark - NSOperation Life Cycle

- (void)main
{
    @autoreleasepool {
        if (self.isCancelled) {
            return;
        }
        
        NSData *rssData = [[NSData alloc] initWithContentsOfURL:_feedURL];
        
        if (self.isCancelled) {
            return;
        }
        
        if (!rssData) {
            NSError *error = [NSError errorWithDomain:@"com.yannickloriot.rssreader" code:0 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil) }];
            [self invokeCompletionBlockWithChannelXML:nil error:error];
            return;
        }
        
        RSSFeedXMLParser *feedXML = [[RSSFeedXMLParser alloc] initWithData:rssData];
        BOOL isParseSucced        = [feedXML parse];
        
        if (self.isCancelled) {
            return;
        }
        
        if (!isParseSucced) {
            NSError *error = [NSError errorWithDomain:@"com.yannickloriot.rssreader" code:0 userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil) }];
            [self invokeCompletionBlockWithChannelXML:nil error:error];
            return;
        }
        
        // Sets the initial source
        RSSFeedChannelXML *channel = feedXML.channel;
        channel.sourceURL          = _feedURL;
        
        if (self.isCancelled) {
            return;
        }
        
        [self invokeCompletionBlockWithChannelXML:feedXML.channel error:nil];
    }
}


#pragma mark - Private Methods

- (void)invokeCompletionBlockWithChannelXML:(RSSFeedChannelXML *)channelXML error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (_feedCompletionBlock) {
            _feedCompletionBlock(error, channelXML);
        }
    });
}

@end
