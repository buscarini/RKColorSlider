//
//  RKColorSlider.m
//  Pods
//
//  Created by Richard Kirk on 1/11/15.
//
//

#import "RKColorSlider.h"

double projectNormal(double n, double start, double end)
{
    return start + (n * (end - start));
}

double normalize(double value, double startValue, double endValue)
{
    return (value - startValue) / (endValue - startValue);
}

double solveLinearEquation(double input, double startValue, double endValue, double outputStart, double outputEnd)
{
    return projectNormal(MAX(0, MIN(1, normalize(input, startValue, endValue))), outputStart, outputEnd);
}


@interface RKColorSlider()
@property (strong, nonatomic) UIImageView *sliderImageView;
@end

@implementation RKColorSlider


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setup];
    }
    return self;
}


- (void)setup
{
	self.offset = -80;
	
    self.sliderImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.sliderImageView.image = [self sliderImage];

    [self addSubview:self.sliderImageView];
    
    self.previewView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, 50, 50)];
    self.previewView.alpha = 0.0;
    self.previewView.layer.cornerRadius = self.previewView.frame.size.width / 2;
    self.previewView.layer.masksToBounds = YES;
    [self addSubview:self.previewView];
    self.clipsToBounds = NO;
}

- (UIImage *)sliderImage
{
    NSString *bundlePath             = [[NSBundle mainBundle] pathForResource:@"RKColorSlider" ofType:@"bundle"];
    NSBundle *bundle                 = [NSBundle bundleWithPath:bundlePath];
    NSString *imagePath = [bundle pathForResource:@"slider@2x" ofType:@"png"];
    return [UIImage imageWithContentsOfFile:imagePath];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{

    [super beginTrackingWithTouch:touch withEvent:event];
	
	CGPoint point = [touch locationInView:self];
	
    [UIView animateWithDuration:0.1 animations:^{
        self.previewView.frame = CGRectMake(point.x, point.y+self.offset,
                                self.previewView.frame.size.width, self.previewView.frame.size.height);
        self.previewView.alpha = 1.0;
    }];
    return YES;
}


- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint point = [touch locationInView:self];
    CGFloat hue = solveLinearEquation(self.frame.size.width-point.x, 90, self.frame.size.width, 0, 1);
    CGFloat s = solveLinearEquation(self.frame.size.width-point.x, 30, 75, 0, 1);
    CGFloat b = solveLinearEquation(self.frame.size.width-point.x, 0, 30, 0, 1);
    _selectedColor = [UIColor colorWithHue:hue saturation:s brightness:b alpha:1.0];
    self.previewView.backgroundColor = _selectedColor;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
	    [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.previewView.frame = CGRectMake(point.x-self.previewView.frame.size.width/2, point.y+self.offset,
                                                self.previewView.frame.size.width, self.previewView.frame.size.height);
		} completion:nil];
	
    return YES;
}


- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.3 animations:^{
        self.previewView.frame = CGRectMake(0, self.previewView.frame.origin.y,
                                            self.previewView.frame.size.width, self.previewView.frame.size.height);
        self.previewView.alpha = 0.0;
    }];
    [super endTrackingWithTouch:touch withEvent:event];
}

@end
