//
//  CAAttendanceController.m
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAAttendanceController.h"
#import "CAModel.h"

@implementation CAAttendanceController
{
    CAModel * _model;
}
@synthesize presentCountLabel = _presentCountLabel;
@synthesize continueButton = _continueButton;
@synthesize whichTeam = _whichTeam;

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [CAModel sharedModel];    
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [_model startAttendanceForTeam:self.whichTeam];
    self.presentCountLabel.text = [NSString stringWithFormat:@"%i / %i", 
                                   [_model numPlayersPresentOnSelectedTeam], [_model numPlayersOnSelectedTeam]];
    
}

- (void)viewDidUnload
{
    [self setPresentCountLabel:nil];
    [self setContinueButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model numPlayersOnSelectedTeam];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if ([_model isPlayerPresent:indexPath.row])
    {
        cell.detailTextLabel.text = @"present";
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];

    }
    else
    {
        cell.detailTextLabel.text = @"absent";
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
    }
    
    cell.textLabel.text = [[_model selectedTeamPlayerAtIndex:indexPath.row] fullname];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_model isPlayerPresent:indexPath.row])
        [_model playerIsAbsent:indexPath.row];
    else
        [_model playerIsPresent:indexPath.row];
    
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    int n = [_model numPlayersPresentOnSelectedTeam];
    self.presentCountLabel.text = [NSString stringWithFormat:@"%i / %i", 
                                   n, [_model numPlayersOnSelectedTeam]];
    if (n >= 2 || (_model.includeCoachRatings && n == 1))
        self.continueButton.hidden = NO;
    else if (n <= 1)
        self.continueButton.hidden = YES;
    
    //[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"attendanceDone"])
    {
        if ([_model numPlayersPresentOnSelectedTeam] <= 1)
            _model.includePeerRatings = NO;
    }
}

- (IBAction)cancelAssessment:(id)sender 
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}


@end
