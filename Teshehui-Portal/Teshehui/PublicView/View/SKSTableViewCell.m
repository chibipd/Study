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

static UIImage *_image = nil;
- (UIView *)expandableView
{
    if (!_image) {
        _image = [UIImage imageNamed:@"expandableImage.png"];
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, _image.size.width, _image.size.height);
    button.frame = frame;
    
    [button setBackgroundImage:_image forState:UIControlStateNormal];
    
    return button;
}

- (void)setIsExpandable:(BOOL)isExpandable
{
//    if (isExpandable)
//        [self setAccessoryView:[self expandableView]];
    
    _isExpandable = isExpandable;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)addIndicatorView
{
    CGPoint point = self.accessoryView.center;
    CGRect bounds = self.accessoryView.bounds;
    
    CGRect frame = CGRectMake((point.x - CGRectGetWidth(bounds) * 1.5), point.y * 1.4, CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(self.bounds) - point.y * 1.4);
    SKSTableViewCellIndicator *indicatorView = [[SKSTableViewCellIndicator alloc] initWithFrame:frame];
    indicatorView.tag = kIndicatorViewTag;
    [self.contentView addSubview:indicatorView];
}

- (void)removeIndicatorView
{
    id indicatorView = [self.contentView viewWithTag:kIndicatorViewTag];
    [indicatorView removeFromSuperview];
}

- (BOOL)containsIndicatorView
{
    return [self.contentView viewWithTag:kIndicatorViewTag] ? YES : NO;
}

@end
