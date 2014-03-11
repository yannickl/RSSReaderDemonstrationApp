//
//  RSSRequestFeedOperation.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RSSFeedChannelXML;

typedef void (^RSSRequestFeedOperationCompletionBlock) (NSError *error, RSSFeedChannelXML *channel);

@interface RSSRequestFeedOperation : NSOperation
@property (nonatomic, strong, readonly) NSURL                        *feedURL;
@property (nonatomic, strong) RSSRequestFeedOperationCompletionBlock feedCompletionBlock;

#pragma mark - Initializers / Constructors

- (id)initWithFeedURL:(NSURL *)feedURL;
+ (instancetype)requestFeedOperationWithURL:(NSURL *)feedURL;

@end
