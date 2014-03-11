//
//  RSSAddFeedViewController.h
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RSSAddFeedViewController : UIViewController
@property (nonatomic, strong) NSManagedObjectContext *mainObjectContext;

@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UIButton    *testURLButton;
@property (weak, nonatomic) IBOutlet UILabel     *statusLabel;
@property (weak, nonatomic) IBOutlet UIView      *currentFeedView;
@property (weak, nonatomic) IBOutlet UILabel     *currentFeedTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel     *currentFeedSummaryLabel;
@property (weak, nonatomic) IBOutlet UIImageView *currentFeedThumbnailImageView;
@property (weak, nonatomic) IBOutlet UIButton    *currentFeedAddButton;

#pragma mark - IBAction Methods

- (IBAction)testFeedURLAction:(id)sender;
- (IBAction)addFeedAction:(id)sender;

@end
