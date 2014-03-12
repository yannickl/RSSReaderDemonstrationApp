//
//  RSSChannelCell.m
//  RssReader
//
//  Created by YannickL on 12/03/14.
//  Copyright (c) 2014 Yannick Loriot. All rights reserved.
//

#import "RSSChannelCell.h"

@implementation RSSChannelCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
