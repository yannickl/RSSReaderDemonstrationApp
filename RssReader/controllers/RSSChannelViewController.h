//
//  RSSChannelViewController.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSChannelViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *refrechButtonItem;

@property (nonatomic, strong) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, strong) NSManagedObjectID      *channelID;


#pragma mark - IBAction

- (IBAction)refreshAction:(id)sender;

@end
