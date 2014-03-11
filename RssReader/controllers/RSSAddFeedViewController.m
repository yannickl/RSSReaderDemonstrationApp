//
//  RSSAddFeedViewController.m
//  RssReader
//
//  Created by YannickL on 10/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSAddFeedViewController.h"
#import "RSSRequestFeedOperation.h"
#import "RSSFeedChannelXML.h"

#import "RSSChannelEntity.h"
#import "RSSItemEntity.h"

#define RSSAddFeedShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define RSSAddFeedHideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

@interface RSSAddFeedViewController ()
@property (nonatomic, strong) NSOperationQueue  *backgroundQueue;
@property (nonatomic, strong) RSSFeedChannelXML *currentChannel;

- (void)testFeedAtURL:(NSURL *)feedURL;

@end

@implementation RSSAddFeedViewController
@synthesize backgroundQueue = _backgroundQueue;
@synthesize currentChannel  = _currentChannel;

#pragma mark - UIViewController Life Cycle

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"currentChannel"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Setup KVO
    [self addObserver:self forKeyPath:@"currentChannel" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial context:nil];
    self.currentChannel = nil;
    
    // Create the background queue to retrieve feeds
    _backgroundQueue                             = [[NSOperationQueue alloc] init];
    _backgroundQueue.maxConcurrentOperationCount = 1;
}

#pragma mark - IBAction Methods

- (IBAction)testFeedURLAction:(id)sender {
    [self testFeedAtURL:[NSURL URLWithString:_urlTextField.text]];
}

- (IBAction)addFeedAction:(id)sender {
    if (_currentChannel) {
        // Create a context to manage entities in the background
        NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        backgroundContext.parentContext           = _mainObjectContext;
        
        [backgroundContext performBlock:^{
            RSSChannelEntity *channelEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Channel" inManagedObjectContext:backgroundContext];
            
            channelEntity.src     = [_currentChannel.sourceURL description];
            channelEntity.title   = _currentChannel.title;
            channelEntity.summary = _currentChannel.summary;
            
            for (RSSFeedChannelXML *itemXML in _currentChannel.items) {
                RSSItemEntity *itemEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Item" inManagedObjectContext:backgroundContext];
                
                itemEntity.title      = itemXML.title;
                itemEntity.summary    = itemXML.summary;
                itemEntity.link       = itemXML.link;
                itemEntity.markAsRead = @(NO);
                
                [channelEntity addItemsObject:itemEntity];
            }
            
            // Push to parent
            NSError *error;
            if (![backgroundContext save:&error]) {
                // handle error
                NSLog(@"error: %@", error);
            }
            
            // save parent to disk asynchronously
            [_mainObjectContext performBlock:^{
                NSError *error;
                if (![_mainObjectContext save:&error]) {
                    // handle error
                    NSLog(@"error: %@", error);
                }
            }];
        }];
    }
}

#pragma mark - Private methods

- (void)testFeedAtURL:(NSURL *)feedURL {
    [_urlTextField resignFirstResponder];
    _testURLButton.enabled = NO;
    
    RSSRequestFeedOperation *requestFeedOperation = [[RSSRequestFeedOperation alloc] initWithFeedURL:feedURL];
    
    __weak typeof(self) weakSelf = self;
    [requestFeedOperation setFeedCompletionBlock:^ (NSError *error, RSSFeedChannelXML *channel) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        weakSelf.testURLButton.enabled = YES;
        weakSelf.currentChannel        = channel;
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [_backgroundQueue addOperation:requestFeedOperation];
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self testFeedAtURL:[NSURL URLWithString:_urlTextField.text]];
    
    return NO;
}

#pragma mark - KVO Delegate Methods

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self && [keyPath isEqualToString:@"currentChannel"]) {
        if (_currentChannel) {
            _currentFeedTitleLabel.text   = _currentChannel.title;
            _currentFeedSummaryLabel.text = _currentChannel.summary;
            
            // Layout the feed description/thumbnail
            CGRect thumbnailFrame = _currentFeedThumbnailImageView.frame;
            CGRect summaryFrame   = _currentFeedSummaryLabel.frame;
            if (_currentChannel.thumbnail) {
                thumbnailFrame.size.width            = thumbnailFrame.size.height;
                _currentFeedThumbnailImageView.frame = thumbnailFrame;
                _currentFeedThumbnailImageView.image = [UIImage imageWithData:_currentChannel.thumbnail];
                
                summaryFrame.size.width        = 169;
                summaryFrame.origin.x          = 111;
                _currentFeedSummaryLabel.frame = summaryFrame;
            }
            else {
                thumbnailFrame.size.width            = 0;
                _currentFeedThumbnailImageView.frame = thumbnailFrame;
                
                summaryFrame.size.width        = 280;
                summaryFrame.origin.x          = 0;
                _currentFeedSummaryLabel.frame = summaryFrame;
            }
        }
        NSLog(@"_currentFeedThumbnailImageView: %@", NSStringFromCGRect(_currentFeedThumbnailImageView.frame));
        _currentFeedView.hidden = (_currentChannel == nil);
    }
}

@end
