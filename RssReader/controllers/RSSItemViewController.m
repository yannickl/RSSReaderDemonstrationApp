//
//  RSSItemViewController.m
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSItemViewController.h"

#import "RSSChannelEntity.h"
#import "RSSItemEntity.h"
#import "NSManagedObject+RssReader.h"

@interface RSSItemViewController ()
@property (nonatomic, strong) RSSItemEntity *currentItem;

/** Marks the current item as read and save it to the database. */
- (void)markItemAsRead;

@end

@implementation RSSItemViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _currentItem = [RSSItemEntity rss_findByID:_itemID inContext:_mainObjectContext];
    self.title   = _currentItem.title;
    
    _shareOnFacebookButton.enabled = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    _shareOnTwitterButton.enabled  = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];

    [self markItemAsRead];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    NSURLRequest *itemURLRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_currentItem.link]];
    [_webView loadRequest:itemURLRequest];
}

#pragma mark - Private Methods

- (void)markItemAsRead
{
    if (![_currentItem.markAsRead boolValue]) {
        [_mainObjectContext performBlock:^{
            _currentItem.markAsRead          = @(YES);
            _currentItem.channel.unreadItems = @([_currentItem.channel.unreadItems integerValue] - 1);
            
            NSError *error;
            if (![_mainObjectContext save:&error]) {
                NSLog(@"error: %@", error);
            }
        }];
    }
}

- (void)shareOnService:(NSString *)serviceType
{
    if ([SLComposeViewController isAvailableForServiceType:serviceType])
    {
        SLComposeViewController *serviceSheet = [SLComposeViewController composeViewControllerForServiceType:serviceType];
        [serviceSheet setInitialText:[NSString stringWithFormat:NSLocalizedString(@"Check out this link! %@", @"Message displayed in when you share a link"), _currentItem.link]];
        [self presentViewController:serviceSheet animated:YES completion:NULL];
    }
}

#pragma mark - IBAction

- (IBAction)openInSafariAction:(id)sender
{
    NSURL *url = [NSURL URLWithString:_currentItem.link];
    
    if (![[UIApplication sharedApplication] openURL:url]) {
        NSLog(@"Failed to open url: %@", [url description]);
    }
}

- (IBAction)shareOnTwitterAction:(id)sender
{
    [self shareOnService:SLServiceTypeTwitter];
}

- (IBAction)shareOnFacebookAction:(id)sender
{
    [self shareOnService:SLServiceTypeFacebook];
}

@end
