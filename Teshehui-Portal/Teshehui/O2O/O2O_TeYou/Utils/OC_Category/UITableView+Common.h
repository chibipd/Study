//
//  UITableView+Common.h
//  Coding_iOS
//
//  Created by ??? on 14-8-5.
//  Copyright (c) 2014年 ???. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UITapImageView.h"

@interface UITableView (Common)
- (void)addRadiusforCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace;
- (void)addLineforPlainCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withLeftSpace:(CGFloat)leftSpace hasSectionLine:(BOOL)hasSectionLine;

//- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr andBlock:(void(^)(id obj))tapAction;
//- (UITapImageView *)getHeaderViewWithStr:(NSString *)headerStr color:(UIColor *)color andBlock:(void(^)(id obj))tapAction;
@end
