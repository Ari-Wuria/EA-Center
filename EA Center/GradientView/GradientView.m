//
//  GradientView.m
//  StoreSearch
//
//  Created by yifeng shen on 2/8/15.
//  Copyright (c) 2015 Tom and Jerry. All rights reserved.
//

#import "GradientView.h"

@implementation GradientView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    const CGFloat conponent[8] = { 0.0f, 0.0f, 0.0f, 0.3f, 0.0f, 0.0f, 0.0f, 0.7f };
    const CGFloat location[2] = { 0.0f, 1.0f };
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(space, conponent, location, 2);
    CGColorSpaceRelease(space);
    
    CGFloat x = CGRectGetMidX(self.bounds);
    CGFloat y = CGRectGetMidY(self.bounds);
    CGPoint point = CGPointMake(x, y);
    CGFloat radius = MAX(x, y);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawRadialGradient(context, gradient, point, 0, point, radius, kCGGradientDrawsAfterEndLocation);
    CGGradientRelease(gradient);
}


@end
