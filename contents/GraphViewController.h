//
//  GraphViewController.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 9/24/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarGraphView.h"

@interface GraphViewController : UIViewController <UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet BarGraphView *barGraph;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *graphEnclosure;

@property (strong, nonatomic) NSString * whichTeam;
@property (strong, nonatomic) NSString * whichPlayer;
@property (strong, nonatomic) NSString * whichQuestion;

@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UILabel *subTitle;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;


@end
