//
//  BarGraphView.h
//  BarGraphTester
//
//  Created by Colin Schatz on 10/21/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BarGraphView : UIView

@property (nonatomic) double minX;
@property (nonatomic) double maxX;
@property (nonatomic) double xTickSpacing;

- (void) addBarWithLabel: (NSString *)label andValue:(double) value;
- (void) doneAddingData;

@end
