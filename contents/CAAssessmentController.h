//
//  CAAssementController.h
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAModel.h"

@interface CAAssessmentController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *raterLabel;
@property (weak, nonatomic) IBOutlet UILabel *raterLabelCaption;
@property (strong, nonatomic) IBOutlet UITextView *instructions;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *answerOptions;
@property (strong, nonatomic) NSArray * buttons;

@end
