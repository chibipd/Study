//
//  HeadMenuView.h
//  YYHealth
//
//  Created by xkun on 15/6/10.
//  Copyright (c) 2015年 xkun. All rights reserved.
//
#import "TopAdvertisingView.h"
#import "UIImageView+WebCache.h"
#import "DefineConfig.h"
#import "NSTimer+Common.h"
@implementation TopAdvertisingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        [self initializeSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeSubviews];
    }
    return self;
}
-(void)initializeSubviews {
    
    DebugNSLog(@"bannerView  == %@",NSStringFromCGRect(self.frame));
    //#pragma mark -- 传入的url
    _curPage = 1;                                    // 显示的是图片数组里的第一张图片
    _curImages = [[NSMutableArray alloc] init];
    _imagesArray = [[NSMutableArray alloc] init];
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [_scrollView setScrollsToTop:NO];
    _scrollView.delegate = self;
    
    _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width * 3, self.frame.size.height);
    
    [self addSubview:_scrollView];
}
- (void)setImagesArray:(NSMutableArray *)imagesArray
{
    if (!imagesArray || [imagesArray count] == 0)
    {
        [_imagesArray addObject:@"login_logo"];

    }
    else
    {
        _imagesArray = imagesArray;
    }
    
    if (imagesArray.count <=1 ) {
        _scrollView.scrollEnabled = NO;
    }else{
        _scrollView.scrollEnabled = YES;
    }

    _totalPage = _imagesArray.count;

    [self refreshScrollView];
}

- (void)setAnimationDuration:(NSTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    if (animationDuration > 0.0)
    {

        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationDuration
                                                               target:self
                                                             selector:@selector(animationTimerDidFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        
        [self.animationTimer pauseTimer];
    }
}


#pragma mark - 响应事件

- (void)animationTimerDidFired:(NSTimer *)timer
{
    CGPoint newOffset = CGPointMake(_scrollView.contentOffset.x + CGRectGetWidth(_scrollView.frame), _scrollView.contentOffset.y);
    [_scrollView setContentOffset:newOffset animated:YES];
}


- (void)refreshScrollView
{
    NSArray *subViews = [_scrollView subviews];
    if([subViews count] != 0)
    {
        [subViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    [self getDisplayImagesWithCurpage:_curPage];
    for (int i = 0; i < _curImages.count; i++)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(_scrollView.frame.size.width * i, 0, _scrollView.frame.size.width, _scrollView.frame.size.height)];
        imageView.userInteractionEnabled = YES;
//        [imageView setContentMode:UIViewContentModeScaleAspectFill]; // 图片填充模式
      //  imageView.image = [UIImage imageNamed:_curImages[i]];
        NSString *urlStirng = nil;
        if (self.imageType == aliyun) {
            //http://o2oalioss.teshehui.com/test/ba527616557e4224880b032fe153873a.jpg@750w_500h_1l_2e
            urlStirng = [NSString stringWithFormat:@"%@@%.0fw_%.0fh_1l_2e",_curImages[i],_scrollView.frame.size.width * 2,280.0f * 2];
            NSLog(@"banner url sring == %@",urlStirng);
        }else{
            urlStirng = [NSString stringWithFormat:@"%@?imageView2/1/w/%.0f/h/%.0f",_curImages[i],_scrollView.frame.size.width * 2,g_fitFloat(@[@180,@211,@233]) * 2];
            NSLog(@"banner url sring == %@",urlStirng);
        }
        

        [imageView sd_setImageWithURL:[NSURL URLWithString:urlStirng] placeholderImage:[UIImage imageNamed:self.imageType == aliyun ? @"ico_logo_bg" : @"loadingpic"]];
        

        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(handleTap:)];
        [imageView addGestureRecognizer:singleTap];
        [_scrollView addSubview:imageView];
    }
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0)];
    
}

- (NSArray *)getDisplayImagesWithCurpage:(NSUInteger)page
{
    NSUInteger pre = [self validPageValue:_curPage - 1];
    NSUInteger last = [self validPageValue:_curPage + 1];
    
    if ([_curImages count] != 0) [_curImages removeAllObjects];
    
    if(_imagesArray.count > pre - 1){
        [_curImages addObject:[_imagesArray objectAtIndex:pre - 1]];
    }
    if (_imagesArray.count > _curPage - 1) {
        [_curImages addObject:[_imagesArray objectAtIndex:_curPage - 1]];
    }
    if (_imagesArray.count > last - 1) {
        [_curImages addObject:[_imagesArray objectAtIndex:last - 1]];
    }
    
    return _curImages;
}

- (NSUInteger)validPageValue:(NSInteger)value
{
    if (value == 0)
    {
        value = _totalPage;                   // value＝1为第一张，value = 0为前面一张
    }
    if (value == _totalPage + 1)
    {
        value = 1;
    }
    return value;
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.animationTimer pauseTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.animationTimer resumeTimerAfterTimeInterval:self.animationDuration];
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    if (aScrollView != _scrollView) {
        return;
    }
    int x = aScrollView.contentOffset.x;
    // 往下翻一张
    if (x >= (2 * _scrollView.frame.size.width))
    {
        _curPage = [self validPageValue:_curPage + 1];
        [self refreshScrollView];
    }
    if (x <= 0)
    {
        _curPage = [self validPageValue:_curPage - 1];
        [self refreshScrollView];
    }
    if ([_delegate respondsToSelector:@selector(topAdvertisingViewCallBack:didScrollImageView:)])
    {
        [_delegate topAdvertisingViewCallBack:self didScrollImageView:_curPage];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)aScrollView
{
    
    
    [_scrollView setContentOffset:CGPointMake(_scrollView.frame.size.width, 0) animated:YES];
}

- (void)handleTap:(UITapGestureRecognizer *)tap
{
    if ([_delegate respondsToSelector:@selector(topAdvertisingViewCallBack:didSelectImageView:)])
    {
        [_delegate topAdvertisingViewCallBack:self didSelectImageView:_curPage];
    }
}




@end
