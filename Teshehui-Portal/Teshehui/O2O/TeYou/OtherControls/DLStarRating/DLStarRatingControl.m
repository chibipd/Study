

#import "DLStarRatingControl.h"
#import "DLStarView.h"
#import "UIView+Subviews.h"


@implementation DLStarRatingControl

@synthesize star, highlightedStar, delegate, isFractionalRatingEnabled;

#pragma mark -
#pragma mark Initialization

- (void)setupView {
	self.clipsToBounds = YES;
	currentIdx = -1;
	star = [UIImage imageNamed:@"star_normal"];
	highlightedStar = [UIImage imageNamed:@"star_hilight"];

	for (int i=0; i<numberOfStars; i++) {
		DLStarView *v = [[DLStarView alloc] initWithDefault:self.star highlighted:self.highlightedStar position:i allowFractions:isFractionalRatingEnabled];
		[self addSubview:v];

	}
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
		numberOfStars = kDefaultNumberOfStars;
        if (isFractionalRatingEnabled)
            numberOfStars *=kNumberOfFractions;
		[self setupView];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		numberOfStars = kDefaultNumberOfStars;
        if (isFractionalRatingEnabled)
            numberOfStars *=kNumberOfFractions;
        [self setupView];

	}
	return self;
}

- (id)initWithFrame:(CGRect)frame andStars:(NSUInteger)_numberOfStars isFractional:(BOOL)isFract{
	self = [super initWithFrame:frame];
	if (self) {
        isFractionalRatingEnabled = isFract;
		numberOfStars = _numberOfStars;
        if (isFractionalRatingEnabled)
            numberOfStars *=kNumberOfFractions;
		[self setupView];
	}
	return self;
}

- (void)layoutSubviews {
	for (int i=0; i < numberOfStars; i++) {
		[(DLStarView*)[self subViewWithTag:i] centerIn:self.frame with:numberOfStars];
	}
}

#pragma mark -
#pragma mark Customization

- (void)setStar:(UIImage*)defaultStarImage highlightedStar:(UIImage*)highlightedStarImage atIndex:(NSInteger)index {
    DLStarView *selectedStar = (DLStarView*)[self subViewWithTag:index];
    
    // check if star exists
    if (!selectedStar) return;
    
    // check images for nil else use default stars
    defaultStarImage = (defaultStarImage) ? defaultStarImage : star;
    highlightedStarImage = (highlightedStarImage) ? highlightedStarImage : highlightedStar;
    
    [selectedStar setStarImage:defaultStarImage highlightedStarImage:highlightedStarImage];
}

#pragma mark -
#pragma mark Touch Handling

- (UIButton*)starForPoint:(CGPoint)point {
	for (int i=0; i < numberOfStars; i++) {
		if (CGRectContainsPoint([self subViewWithTag:i].frame, point)) {
			return (UIButton*)[self subViewWithTag:i];
		}
	}
	return nil;
}

- (void)disableStarsDownToExclusive:(NSInteger)idx {
	for (NSInteger i=numberOfStars; i > idx; --i) {
		UIButton *b = (UIButton*)[self subViewWithTag:i];
		b.highlighted = NO;
	}
}

- (void)disableStarsDownTo:(NSInteger)idx {
	for (NSInteger i=numberOfStars; i >= idx; --i) {
		UIButton *b = (UIButton*)[self subViewWithTag:i];
		b.highlighted = NO;
	}
}


- (void)enableStarsUpTo:(NSInteger)idx {
	for (int i=0; i <= idx; i++) {
		UIButton *b = (UIButton*)[self subViewWithTag:i];
		b.highlighted = YES;
	}
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];	
	UIButton *pressedButton = [self starForPoint:point];
	if (pressedButton) {
		NSInteger idx = pressedButton.tag;
		if (pressedButton.highlighted) {
			[self disableStarsDownToExclusive:idx];
		} else {
			[self enableStarsUpTo:idx];
		}		
		currentIdx = idx;
	} 
	return YES;		
}

- (void)cancelTrackingWithEvent:(UIEvent *)event {
	[super cancelTrackingWithEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	CGPoint point = [touch locationInView:self];
	
	UIButton *pressedButton = [self starForPoint:point];
	if (pressedButton) {
		NSInteger idx = pressedButton.tag;
		UIButton *currentButton = (UIButton*)[self subViewWithTag:currentIdx];
		
		if (idx < currentIdx) {
			currentButton.highlighted = NO;
			currentIdx = idx;
			[self disableStarsDownToExclusive:idx];
		} else if (idx > currentIdx) {
			currentButton.highlighted = YES;
			pressedButton.highlighted = YES;
			currentIdx = idx;
			[self enableStarsUpTo:idx];
		}
	} else if (point.x < [self subViewWithTag:0].frame.origin.x) {
		((UIButton*)[self subViewWithTag:0]).highlighted = NO;
		currentIdx = -1;
		[self disableStarsDownToExclusive:0];
	}
	return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
	[self.delegate newRating:self :self.rating];
	[super endTrackingWithTouch:touch withEvent:event];
}

#pragma mark -
#pragma mark Rating Property

- (void)setRating:(CGFloat)_rating {
    if (isFractionalRatingEnabled) {
        _rating *=kNumberOfFractions;
    }
	[self disableStarsDownTo:0];
	currentIdx = (int)_rating-1;
	[self enableStarsUpTo:currentIdx];
}

- (CGFloat)rating {
    if (isFractionalRatingEnabled) {
        return (CGFloat)(currentIdx+1)/kNumberOfFractions;
    }
	return (NSUInteger)currentIdx+1;
}


#pragma mark -
#pragma mark Memory Management

- (void)dealloc {
	self.star = nil;
	self.highlightedStar = nil;
	self.delegate = nil;

}

@end
