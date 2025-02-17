//
//  SKSTableViewCell.m
//  SKSTableView
//
//  Created by Sakkaras on 26/12/13.
//  Copyright (c) 2013 Sakkaras. All rights reserved.
//

#import "SKSTableViewCell.h"
#import "SKSTableViewCellIndicator.h"

#define kIndicatorViewTag -1

@interface SKSTableViewCell ()

@end

@implementation SKSTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setIsExpandable:NO];
        [self setIsExpanded:NO];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)setIsExpandable:(BOOL)isExpandable
{
    _isExpandable = isExpandable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


@end
