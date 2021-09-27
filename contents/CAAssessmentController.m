//
//  CAAssementController.m
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAAssessmentController.h"
#import "CAViewController.h"
#import "CAModel.h"

@interface CAAssessmentController ()
- (void) gotoNextItem;
@end

@implementation CAAssessmentController
{
    CAModel * _model;
    NSArray * _answerList;
}
@synthesize raterLabel = _raterLabel;
@synthesize raterLabelCaption = _raterLabelCaption;
@synthesize instructions = _instructions;
@synthesize answerOptions = _answerOptions;
@synthesize buttons = _buttons;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


- (void) viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;    
    _model = [CAModel sharedModel];
    _buttons = [_answerOptions sortedArrayUsingComparator: ^(id a, id b) { return [a tag] - [b tag]; }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [_model startAssessments];
    [self gotoNextItem];
}

- (void)viewDidUnload
{
    [self setInstructions:nil];
    [self setAnswerOptions:nil];
    [self setRaterLabel:nil];
    [self setRaterLabelCaption:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (IBAction)userTouchedButton:(UIButton*)sender 
{
    if (self.raterLabelCaption.hidden == NO)
    {
        [_model recordRating:[((AnswerChoice *)[_answerList objectAtIndex:sender.tag]) value]];
    }
    [self gotoNextItem];
}

#pragma mark -
#pragma mark Internal Update Step

- (void) gotoNextItem
{
    NSArray * pair = [_model getNextAssessmentStep];
    if (pair == nil)
    {
        CAViewController * orig = (CAViewController *)self.navigationController.tabBarController.presentingViewController;
        [self.navigationController popToRootViewControllerAnimated:YES];
        [orig restoreStartScreen];
        [orig dismissModalViewControllerAnimated:YES];
        return;
    }
    
    
    if ([[pair objectAtIndex:0] isEqual:[NSNull null]])
    {
        if (_model.includePeerRatings)
            self.instructions.text = @"Evaluation is done. Please return the device to the coach/manager.";
        else
            self.instructions.text = @"Evaluation is done. The screen will now lock.";
        self.raterLabel.text = @"";
        self.raterLabelCaption.hidden = YES;
        for (int i = 1; i < 5; i++)
        {
            ((UIButton *)[_buttons objectAtIndex:i]).hidden = YES;
        }
        [((UIButton *)[_buttons objectAtIndex:0]) setTitle:@"Ok" forState:UIControlStateNormal];
    }
    else if ([[pair objectAtIndex:1] isEqual:[NSNull null]])
    {
        // Switch to next rater
        Player * rater = [pair objectAtIndex:0];
        self.raterLabel.text = rater.fullname;
        self.raterLabel.hidden = YES;
        self.raterLabelCaption.hidden = YES;
        
        if (rater.team == nil)
        {
            // rater is the coach him/herself
            self.instructions.text = @"Ready to enter manager/coach's ratings.\n(Do NOT hand the device to a team member.)";
        }
        else
        {
            self.instructions.text = [NSString stringWithFormat:@"Please hand the device to %@ now.",
                                  rater.fullname];
        }
        
        [((UIButton*)[_buttons objectAtIndex:0]) setTitle:@"Continue" forState:UIControlStateNormal];
        for (int i = 1; i < 5; i++)
        {
            ((UIButton *)[_buttons objectAtIndex:i]).hidden = YES;
        }
    }
    else 
    {
        Question * question = [pair objectAtIndex:0];
        Player * playerToRate = [pair objectAtIndex:1];     
        self.instructions.text = [question.prompt stringByReplacingOccurrencesOfString:@"*" withString:[playerToRate.fullname uppercaseString]];
        self.raterLabel.hidden = NO;
        self.raterLabelCaption.hidden = NO;
        _answerList = [question answersInDescendingValueOrder];
        for (int i = 0; i < 5; i++)
        {
            ((UIButton *)[_buttons objectAtIndex:i]).hidden = NO;
            [((UIButton *)[_buttons objectAtIndex:i]) setTitle:[[_answerList objectAtIndex:i] answer]
                                                      forState:UIControlStateNormal];
        }
    }
}


@end
