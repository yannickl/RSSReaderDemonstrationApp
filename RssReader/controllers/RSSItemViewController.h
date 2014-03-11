//
//  RSSItemViewController.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSItemViewController : UIViewController
@property (nonatomic, strong) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, strong) NSManagedObjectID      *itemID;

@end
