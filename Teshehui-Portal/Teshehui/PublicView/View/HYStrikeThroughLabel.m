//
//  HYStrikeThroughLabel.m
//  Teshehui
//
//  Created by 回亿资本 on 14-2-14.
//  Copyright (c) 2014年 HY.Inc. All rights reserved.
//

#import "HYStrikeThroughLabel.h"

@implementation HYStrikeThroughLabel

@synthesize strikeThroughEnabled = _strikeThroughEnabled;

- (void)drawTextInRect:(CGRect)rect{
    [super drawTextInRect:rect];
    CGSize textSize = [[self text] sizeWithFont:[self font]];
    CGFloat strikeWidth = textSize.width;
    CGRect lineRect;
    
    if ([self textAlignment] == NSTextAlignmentRight) {
        lineRect = CGRectMake(rect.size.width - strikeWidth, rect.size.height/2, strikeWidth, 1);
    } else if ([self textAlignment] == NSTextAlignmentCenter) {
        lineRect = CGRectMake(rect.size.width/2 - strikeWidth/2, rect.size.height/2, strikeWidth, 1);
    } else {
        lineRect = CGRectMake(0, rect.size.height/2, strikeWidth, 1);
    }
    
    if (_strikeThroughEnabled) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextFillRect(context, lineRect);
    }
}

- (void)setStrikeThroughEnabled:(BOOL)strikeThroughEnabled {
    
    _strikeThroughEnabled = strikeThroughEnabled;
    
    NSString *tempText = [self.text copy];
    self.text = @"";
    self.text = tempText;
}

@end

