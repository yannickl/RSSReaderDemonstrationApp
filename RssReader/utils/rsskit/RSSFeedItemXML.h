//
//  RSSFeedItemXML.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSSFeedItemXML : NSObject
@property (nonatomic, strong) NSString *summary;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, strong) NSDate   *pubDate;

@end
