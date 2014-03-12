//
//  RSSItemViewController.h
//  RssReader
//
//  Created by YannickL on 11/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>

@interface RSSItemViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIButton  *shareOnTwitterButton;
@property (weak, nonatomic) IBOutlet UIButton  *shareOnFacebookButton;

@property (nonatomic, strong) NSManagedObjectContext *mainObjectContext;
@property (nonatomic, strong) NSManagedObjectID      *itemID;

#pragma mark - IBAction

- (IBAction)openInSafariAction:(id)sender;
- (IBAction)shareOnTwitterAction:(id)sender;
- (IBAction)shareOnFacebookAction:(id)sender;


@end
