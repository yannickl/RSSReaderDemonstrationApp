//
//  RSSItemEntity.h
//  RssReader
//
//  Created by YannickL on 12/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSChannelEntity;

@interface RSSItemEntity : NSManagedObject

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSNumber * markAsRead;
@property (nonatomic, retain) NSDate * pubDate;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) RSSChannelEntity *channel;

@end
