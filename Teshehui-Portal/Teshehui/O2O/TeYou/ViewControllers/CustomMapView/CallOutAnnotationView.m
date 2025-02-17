

#import "CallOutAnnotationView.h"
#import <QuartzCore/QuartzCore.h>
#include "DefineConfig.h"
@interface CallOutAnnotationView ()
@property (nonatomic,weak)id<CallOutAnnotationViewDelegate>delegate;
@end

@implementation CallOutAnnotationView

- (id)initWithAnnotation:(id<BMKAnnotation>)annotation
         reuseIdentifier:(NSString *)reuseIdentifier
                delegate:(id<CallOutAnnotationViewDelegate>)delegate
{
    self = [super initWithAnnotation:annotation
                     reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.canShowCallout = NO;
        self.centerOffset = CGPointMake(0, g_fitFloat(@[@(-55),@(-55),@(-55)]));
        self.frame = CGRectMake(0, 0, kScreen_Width - g_fitFloat(@[@80,@80,@100]), g_fitFloat(@[@95,@75,@75]));
        if (delegate) {
            self.delegate = delegate;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
            [self addGestureRecognizer:tap];
        }
        
        UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - Arror_height)];
        contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:contentView];
        self.contentView = contentView;
    }
    NSLog(@"%@",NSStringFromCGRect(self.contentView.frame));
    return self;
}

- (void)tapAction
{
    if ([_delegate respondsToSelector:@selector(didSelectAnnotationView:)]) {
        [_delegate didSelectAnnotationView:self];
    }
}

#pragma mark -
#pragma mark draw

- (void)getDrawPath:(CGContextRef)context rect:(CGRect)rect
{
    CGRect rrect = rect;
	CGFloat radius = 6.0;
    
	CGFloat minx = CGRectGetMinX(rrect),
    midx = CGRectGetMidX(rrect), 
    maxx = CGRectGetMaxX(rrect);
	CGFloat miny = CGRectGetMinY(rrect),
    maxy = CGRectGetMaxY(rrect)-Arror_height;
    
    CGContextMoveToPoint(context, midx+Arror_height, maxy);
    CGContextAddLineToPoint(context,midx, maxy+Arror_height);
    CGContextAddLineToPoint(context,midx-Arror_height, maxy);
    
    CGContextAddArcToPoint(context, minx, maxy, minx, miny, radius);
    CGContextAddArcToPoint(context, minx, minx, maxx, miny, radius);
    CGContextAddArcToPoint(context, maxx, miny, maxx, maxx, radius);
    CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
    CGContextClosePath(context);
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    [self getDrawPath:context rect:CGRectMake(0, 0, kScreen_Width - g_fitFloat(@[@80,@80,@100]), g_fitFloat(@[@80,@75,@75]))];
    CGContextFillPath(context);
    
    CGPathRef path = CGContextCopyPath(context);
    
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    self.layer.shadowOpacity = 1;
    
    //insert
    self.layer.shadowPath = path;

}
@end
