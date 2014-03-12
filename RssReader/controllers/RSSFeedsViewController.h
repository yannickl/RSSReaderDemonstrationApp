//
//  RSSFeedsViewController.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RSSFetchedDataSourceProtocol.h"

@interface RSSFeedsViewController : UITableViewController <RSSFetchedDataSourceDelegate>
@property (nonatomic, strong) NSManagedObjectContext *mainObjectContext;

@end
