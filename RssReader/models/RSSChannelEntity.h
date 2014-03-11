//
//  RSSChannelEntity.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RSSItemEntity;

@interface RSSChannelEntity : NSManagedObject

@property (nonatomic, retain) NSString * link;
@property (nonatomic, retain) NSString * src;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSData * thumbnail;
@property (nonatomic, retain) NSSet *items;
@end

@interface RSSChannelEntity (CoreDataGeneratedAccessors)

- (void)addItemsObject:(RSSItemEntity *)value;
- (void)removeItemsObject:(RSSItemEntity *)value;
- (void)addItems:(NSSet *)values;
- (void)removeItems:(NSSet *)values;

@end
