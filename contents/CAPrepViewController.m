//
//  CADetailViewController.m
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAPrepViewController.h"
#import "CADetailViewController.h"
#import "CAModel.h"
#import "AttendanceRecord.h"

@implementation CAPrepViewController
{
    CAModel * _model;
}
@synthesize whichPlayer = _whichPlayer;
@synthesize whichTeam = _whichTeam;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_whichPlayer == nil)
        self.navigationItem.title = @"Team Summary";
    else
        self.navigationItem.title = _whichPlayer.fullname;
    _model = [CAModel sharedModel];
    if (_whichPlayer == nil)
        [_model loadRatingsForTeam: _whichTeam];
    else
        [_model loadRatingsForPlayer:_whichPlayer];
    
    //NSLog(@"HERE, player = %@, team = %@", _whichPlayer, _whichTeam);
    

    Player * coachObj = _model.coachObject;
    int totalDays = [_model numDaysWithAttendanceData];
    int presentDays = 0;
    int peerRatings = 0, coachRatings = 0;
    NSMutableSet * peerQuestionSet = [NSMutableSet set];
    NSMutableSet * coachQuestionSet = [NSMutableSet set];
    
    if (_whichPlayer != nil)
    {
        for (Rating * r in _whichPlayer.ratingsReceived)
        {
            Player * rater = r.rater;
            if ([rater isEqual:coachObj])
            {
                [coachQuestionSet addObject:r.question.objectID];
                coachRatings++;
            }
            else
            {
                [peerQuestionSet addObject:r.question.objectID];
                peerRatings++;
            }
        }
        
        for (int i = 0; i < totalDays; i++)
        {
            if ([_model wasPlayer:_whichPlayer presentOnDayIndex:i])
                presentDays++;
        }
        self.attendanceLabel.text = [NSString stringWithFormat:@"%@\n%@",
                                     MaybePlural(@"day", totalDays),
                                     MaybePlural(@"absence", totalDays - presentDays)];
    }
    else
    {
        double playerCount = 0;
        
        for (Player * p in _whichTeam.members)
        {
            for (Rating * r in p.ratingsReceived)
            {
                Player * rater = r.rater;
                if ([rater isEqual:coachObj])
                {
                    [coachQuestionSet addObject:r.question.objectID];
                    coachRatings++;
                }
                else
                {
                    [peerQuestionSet addObject:r.question.objectID];
                    peerRatings++;
                }
            }
        }
        
        for (int i = 0; i < totalDays; i++)
        {
            playerCount += [_model numPlayersPresentForDayIndex:i];
        }
        self.attendanceLabel.text = [NSString stringWithFormat:@"%@\n%.1f members present on average",
         MaybePlural(@"day", totalDays),
                                     totalDays > 0 ? playerCount / totalDays: 0];
    }
    self.peerScoreLabel.text = [NSString stringWithFormat:@"Peer evaluations:\n%@ for %i questions", MaybePlural(@"rating", peerRatings), peerQuestionSet.count];
    self.coachScoreLabel.text = [NSString stringWithFormat:@"Coach/manager evaluations:\n%@ for %i questions", MaybePlural(@"rating", coachRatings), coachQuestionSet.count];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setPeerScoreLabel:nil];
    [self setCoachScoreLabel:nil];
    [self setAttendanceLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        if (indexPath.row == 0)
            _model.resultsFilter = ResultsUsePeerRatingsOnly;
        else
            _model.ResultsFilter = ResultsUseCoachRatingsOnly;
        
        [self performSegueWithIdentifier:@"scoreSegue" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"attendanceSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ((CADetailViewController*)segue.destinationViewController).whichTeam = self.whichTeam;
    ((CADetailViewController*)segue.destinationViewController).whichPlayer = self.whichPlayer;
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Back"
                                      style:UIBarButtonItemStyleBordered
                                     target:nil
                                      action:nil];
}


@end
