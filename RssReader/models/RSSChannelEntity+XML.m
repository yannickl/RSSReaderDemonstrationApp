//
//  RSSChannelEntity+XML.m
//  RssReader
//
//  Created by YannickL on 12/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSChannelEntity+XML.h"

#import "RSSItemEntity.h"
#import "NSManagedObject+RssReader.h"

#import "RSSFeedChannelXML.h"

@implementation RSSChannelEntity (XML)

- (NSURL *)xml_sourceURL
{
    return [NSURL URLWithString:self.src];
}

+ (void)xml_insertOrUpdateChannelFromXML:(RSSFeedChannelXML *)channelXML inContext:(NSManagedObjectContext *)context completionBlock:(void (^) ())completionBlock
{
    // Create a context to manage entities in the background
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    backgroundContext.parentContext           = context;
    
    [backgroundContext performBlock:^{
        RSSChannelEntity *internalChannel = [RSSChannelEntity rss_findFirstByAttribute:@"src" withValue:channelXML.sourceURL inContext:backgroundContext];
        
        if (!internalChannel) {
            // If no channel with the given source exists
            RSSChannelEntity *channelEntity = [RSSChannelEntity rss_insertNewObjectIntoContext:backgroundContext];
            channelEntity.src               = [channelXML.sourceURL description];
            channelEntity.title             = channelXML.title;
            channelEntity.summary           = channelXML.summary;
            channelEntity.unreadItems       = @(channelXML.items.count);
            
            for (RSSFeedItemXML *itemXML in channelXML.items) {
                RSSItemEntity *itemEntity = [RSSItemEntity rss_insertNewObjectIntoContext:backgroundContext];
                itemEntity.guid           = itemXML.guid;
                itemEntity.title          = itemXML.title;
                itemEntity.summary        = itemXML.summary;
                itemEntity.link           = itemXML.link;
                itemEntity.pubDate        = itemXML.pubDate ?: [NSDate date];
                itemEntity.markAsRead     = @(NO);
                
                [channelEntity addItemsObject:itemEntity];
            }
        }
        else {
            // Otherwise, merge the changes
            NSArray *sortedItemsXML = [channelXML.items sortedArrayUsingComparator:^NSComparisonResult(RSSFeedItemXML *obj1, RSSFeedItemXML *obj2) {
                return [obj1.guid compare:obj2.guid];
            }];
            
            // Build the item ids list
            NSMutableArray *itemIDs = [NSMutableArray arrayWithCapacity:sortedItemsXML.count];
            for (RSSFeedItemXML *itemXML in sortedItemsXML) {
                [itemIDs addObject:itemXML.guid];
            }
            
            // Retrieve the items already saved in core data
            NSFetchRequest *fetchRequest = [RSSItemEntity rss_fetchRequestInContext:backgroundContext];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(channel == %@) AND (guid IN %@)", internalChannel.objectID, itemIDs]];
            [fetchRequest setSortDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"guid" ascending:YES]]];

            NSError *error;
            NSArray *itemEntitiesMatchingWithIDs = [backgroundContext executeFetchRequest:fetchRequest error:&error];
            
            if (!error) {
                // Check whether we need to add the item or just skip it
                NSInteger currentIndex   = 0;
                NSInteger markerPosition = 0;
                NSInteger newItemCount   = [itemIDs count];
                while (currentIndex < newItemCount) {
                    NSString *currentItemXMLID    = [itemIDs objectAtIndex:currentIndex];
                    NSString *currentItemEntityID = [(RSSItemEntity *)[itemEntitiesMatchingWithIDs objectAtIndex:markerPosition] guid];

                    if ([currentItemXMLID isEqual:currentItemEntityID]) {
                        // The item already exists so we skip it
                        markerPosition++;
                    }
                    else {
                        RSSFeedItemXML *currentItemXML = [sortedItemsXML objectAtIndex:currentIndex];
                        
                        RSSItemEntity *itemEntity = [RSSItemEntity rss_insertNewObjectIntoContext:backgroundContext];
                        itemEntity.guid           = currentItemXML.guid;
                        itemEntity.title          = currentItemXML.title;
                        itemEntity.summary        = currentItemXML.summary;
                        itemEntity.link           = currentItemXML.link;
                        itemEntity.pubDate        = currentItemXML.pubDate ?: [NSDate date];
                        itemEntity.markAsRead     = @(NO);
                        
                        [internalChannel addItemsObject:itemEntity];
                        
                        [internalChannel setUnreadItems:@([internalChannel.unreadItems integerValue] + 1)];
                    }
                    currentIndex++;
                }
            }
        }
        
        // Push to parent
        NSError *childError;
        if (![backgroundContext save:&childError]) {
            // handle error
            NSLog(@"childError: %@", childError);
        }
        
        [context performBlock:^ {
            NSError *parentError;
            if (![context save:&parentError]) {
                // handle error
                NSLog(@"error: %@", parentError);
            }
            
            if (completionBlock) {
                completionBlock();
            }
        }];
    }];
}

@end
