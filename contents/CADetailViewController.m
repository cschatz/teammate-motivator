//
//  CADetailViewController.m
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CADetailViewController.h"
#import "CAModel.h"
#import "CustomTableViewCell.h"
#import "GraphViewController.h"


@implementation CADetailViewController
{
    CAModel * _model;
}

@synthesize whichPlayer = _whichPlayer;
@synthesize whichTeam = _whichTeam;
@synthesize tableView = _tableView;
@synthesize extraInstructions = _extraInstructions;
@synthesize extraInstructions2 = _extraInstructions2;


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (_whichPlayer == nil)
        self.navigationItem.title = _whichTeam.name;
    else
        self.navigationItem.title = _whichPlayer.fullname;
    _model = [CAModel sharedModel];
    
    if (_model.resultsFilter == ResultsUsePeerRatingsOnly)
    {
        self.extraInstructions.text = @"Peer Evaluations";
    }
    else if (_model.resultsFilter == ResultsUseCoachRatingsOnly)
    {
        self.extraInstructions.text = @"Coach/Manager Evaluations";
    }
     
    if (self.whichPlayer == nil)
    {
        self.extraInstructions2.text = @"Tap an entry for player comparison";
    }
    else
    {
        self.extraInstructions2.text = @"Tap an entry for evaluation history";
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (_whichPlayer == nil)
        [_model loadRatingsForTeam:_whichTeam];
    else
        [_model loadRatingsForPlayer:_whichPlayer];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setExtraInstructions:nil];
    [self setExtraInstructions2:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_whichPlayer == nil)
        return 1;
    else
        //return 2;
        return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //if (section == 0)
    {
        if (_whichPlayer == nil)    
           // return [NSString stringWithFormat:@"Team Average (Last %i Scores)", RATING_WINDOW];
            return nil;
        else
            return [NSString stringWithFormat:@"Average (Last %i Scores)",
                RATING_WINDOW];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //DLog(@"Num rows = %i", [_model questionsWithRatingsForSection:section]);
    return [_model questionsWithRatingsForSection:section];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
    NSString * replacement;

    cell.selectionStyle = UITableViewCellSelectionStyleBlue;

    if (self.whichPlayer == nil)
    {
        replacement = @"___";
    }
    else
    {
        replacement = _whichPlayer.fname;
    }
    
    NSString * questionText = [[_model questionForIndexPath:indexPath] stringByReplacingOccurrencesOfString:@"*" withString:replacement];
    
    if (_whichPlayer == nil)
    {
        cell.textLabel.text = questionText;
    }
    else
    {
        UILabel * itemLabel = (UILabel *) [cell viewWithTag:1];
        UILabel * scoreLabel = (UILabel *) [cell viewWithTag:3];
        UIView * graphBar = (UIView *) [cell viewWithTag:2];
        
        itemLabel.text = questionText;

        CGSize result = [itemLabel.text
                         sizeWithFont:itemLabel.font 
                        constrainedToSize:CGSizeMake(itemLabel.frame.size.width, MAXFLOAT)
                        lineBreakMode:UILineBreakModeWordWrap];
        
        itemLabel.frame = CGRectMake(itemLabel.frame.origin.x, 
                                         itemLabel.frame.origin.y,
                                         itemLabel.frame.size.width,
                                        result.height);
        
        double value = [_model averageForIndexPath:indexPath];
        
        scoreLabel.text = [NSString stringWithFormat:@"%.1f", value];
        
        CGRect outerFrame = [graphBar superview].frame;
        [graphBar setFrame:CGRectMake(0, 0,
                                           outerFrame.size.width / 6 * (value + 1),
                                           outerFrame.size.height)];
        double frac = (value - 1) / 4;
        graphBar.backgroundColor = [UIColor 
                                          colorWithHue:0.35
                                          saturation:frac
                                          brightness:0.6
                                         alpha: 1];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    
    if (_whichPlayer == nil)
        CellIdentifier = @"NoStatsCell";
    else
        CellIdentifier = @"StatsCell";
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 400)];
    view.alpha = 0;
    return view;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"graphSegue" sender:[tableView cellForRowAtIndexPath:indexPath]];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    GraphViewController * dest = [segue destinationViewController];
    NSString * unReplacedPrompt = [_model questionForIndexPath:[self.tableView indexPathForSelectedRow]];
    
    dest.hidesBottomBarWhenPushed = YES;
    
    if (_whichPlayer == nil)
    {

        [_model loadRatingsForQuestion:unReplacedPrompt forTeam:_whichTeam];
        dest.whichTeam = [_whichTeam name];
        dest.whichQuestion = unReplacedPrompt;
        dest.whichPlayer = nil;
    }
    else
    {
        dest.whichPlayer = [_whichPlayer fullname];
        dest.whichTeam = nil;
        dest.whichQuestion = unReplacedPrompt;
    }
}


@end
