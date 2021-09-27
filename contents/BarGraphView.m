//
//  BarGraphView.m
//  BarGraphTester
//
//  Created by Colin Schatz on 10/21/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "BarGraphView.h"

#define LABELSIZE 14
#define TICKLEN 10
#define PADDING 10

#define XLABELHEIGHT 20
#define XLABELWIDTH 15

#define XLABELSPACING 5 // away from axes
#define YLABELSPACING 5 // away from axes

#define BARWIDTH 35
#define BARSPACING 15

@interface BarGraphView ()

- (void) setLayout;

@end


@implementation BarGraphView
{
    int _xLeft;
    int _xRight;
    int _yBottom;
    int _yTop;
    
    NSMutableArray * labels;
    NSMutableArray * values;
}

@synthesize minX = _minX, maxX = _maxX, xTickSpacing = _xTickSpacing;


- (id)initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super initWithCoder:aDecoder]) 
    {
        labels = [NSMutableArray array];
        values = [NSMutableArray array];
        [self setLayout];
    }
    return self;
}



- (void)setMinX:(double)minX
{
    _minX = minX;
    [self setNeedsDisplay];
}

- (void)setMaxX:(double)maxX
{
    
    if (maxX <= _minX)
    {
        NSLog(@"FATAL ERROR: Invalid maxX, should be bigger than %.1f", _minX);
        abort();
    }
    _maxX = maxX;
    [self setNeedsDisplay];
}

- (void)setXTickSpacing:(double)xTickSpacing
{
    _xTickSpacing = xTickSpacing;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (labels.count == 0)
        return;
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [UIColor blackColor].CGColor);
    
    int i = 0;
    for (NSString * label in labels)
    {
        float height = [label sizeWithFont:[UIFont systemFontOfSize:LABELSIZE]].height;
        CGRect textRect = CGRectMake(PADDING, _yTop + BARSPACING + i*(BARWIDTH + BARSPACING) + (BARWIDTH - height)/2, _xLeft - PADDING - YLABELSPACING, height);
        [label drawInRect:textRect withFont:[UIFont systemFontOfSize:LABELSIZE] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentLeft];
        i++;
    }
    CGContextSetLineWidth(c, 1);
    CGContextSetStrokeColorWithColor(c, [UIColor darkGrayColor].CGColor);
    for (double xval = _minX; xval <= _maxX; xval += _xTickSpacing)
    {
        double tickPos = _xLeft + (xval + _xTickSpacing - _minX) * (_xRight - _xLeft) / (_maxX - _minX + _xTickSpacing);
        CGContextMoveToPoint(c, tickPos, _yTop);
        CGContextAddLineToPoint(c, tickPos, _yBottom + TICKLEN);
        CGContextStrokePath(c);
        [[NSString stringWithFormat:@"%.0f", xval] drawInRect:CGRectMake(tickPos-XLABELWIDTH/2.0, _yBottom + TICKLEN, XLABELWIDTH, XLABELHEIGHT) withFont:[UIFont systemFontOfSize:18] lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
    }
    i = 0;
    for (NSNumber * num in values)
    {
        double barLength = ([num doubleValue] + _xTickSpacing - _minX)  / (_maxX - _minX + _xTickSpacing) * (_xRight - _xLeft);
        double frac = ([num doubleValue] - _minX) / (_maxX - _minX);
        CGContextSetFillColorWithColor(c,
                                       [UIColor 
                                        colorWithHue:0.35
                                        saturation:frac
                                        brightness:0.6
                                        alpha:1].CGColor);
        CGContextFillRect(c, CGRectMake(_xLeft, _yTop + BARSPACING + i*(BARWIDTH + BARSPACING), barLength, BARWIDTH));
        i++;
    }

    // axes
    CGContextSetLineWidth(c, 3);
    CGContextSetStrokeColorWithColor(c, [UIColor darkGrayColor].CGColor);
    CGContextMoveToPoint(c, _xLeft, _yTop);
    CGContextAddLineToPoint(c, _xLeft, _yBottom + TICKLEN);
    CGContextStrokePath(c);
    CGContextMoveToPoint(c, _xLeft - TICKLEN, _yBottom);
    CGContextAddLineToPoint(c, _xRight + TICKLEN, _yBottom);
    CGContextStrokePath(c);

}

- (void) addBarWithLabel: (NSString *)label andValue:(double) value
{
   [labels insertObject:label atIndex:0];
   [values insertObject:[NSNumber numberWithDouble:value] atIndex:0];
}

- (void) setLayout
{
    double maxTextWidth = 0;
    for (NSString * label in labels)
    {
        float thisWidth =  [label sizeWithFont:[UIFont systemFontOfSize:LABELSIZE]].width;
        if (thisWidth > maxTextWidth)
        maxTextWidth = thisWidth;
    }
    
    double barTotalHeight = labels.count * (BARWIDTH + BARSPACING) + BARSPACING;
    
    _xLeft = PADDING + maxTextWidth + YLABELSPACING;
    _xRight = self.frame.size.width - PADDING - TICKLEN;
    _yBottom = PADDING + barTotalHeight;
    _yTop = PADDING;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y,
                            self.frame.size.width, barTotalHeight + PADDING*2 + XLABELHEIGHT + TICKLEN);
}

- (void) doneAddingData
{
    [self setLayout];
    [self setNeedsDisplay];
}
@end
