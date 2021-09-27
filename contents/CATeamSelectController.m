//
//  CATeamSelectController.m
//  iCoach
//
//  Created by Colin Schatz on 3/24/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CATeamSelectController.h"
#import "CAAttendanceController.h"

@implementation CATeamSelectController
{
    bool _someTeamSelected;
    Team * _selectedTeam;
}

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize tableView = _tableView;
@synthesize peerRatingControl = _peerRatingControl;
@synthesize coachRatingControl = _coachRatingControl;
@synthesize okButton = _okButton;

// model getter
- (CAModel *) model
{
    return [CAModel sharedModel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) updateOkButton
{
    int yesCount = self.peerRatingControl.selectedSegmentIndex +
                self.coachRatingControl.selectedSegmentIndex;
    if (self.okButton.hidden == YES)
    {
        if (_someTeamSelected && yesCount > 0)
            self.okButton.hidden = NO;
    }
    else
    {
        if (!_someTeamSelected || yesCount == 0)
            self.okButton.hidden = YES;
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [self setPeerRatingControl:nil];
    [self setCoachRatingControl:nil];
    [self setOkButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error when fetching %@, %@", error, [error userInfo]);
		abort();
	}
    [self.tableView reloadData];
    _someTeamSelected = NO;
    [self updateOkButton];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    DLog(@"Will rotate to %i", toInterfaceOrientation);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = ([[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects]);
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"PlainCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    Team * team = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = team.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _someTeamSelected = YES;
    _selectedTeam = [_fetchedResultsController objectAtIndexPath:indexPath];
    [self updateOkButton];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"teamPicked"])
    {
        CAAttendanceController * dest = segue.destinationViewController;
        dest.whichTeam = _selectedTeam;
        self.model.includePeerRatings = (self.peerRatingControl.selectedSegmentIndex == 1);
        self.model.includeCoachRatings = (self.coachRatingControl.selectedSegmentIndex == 1);
    }
    else
    {
        NSLog(@"INTERNAL ERROR. Seque from TeamSelectController wasn't 'teamPicked'");
    }
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [self.model fetchedResultsControllerForCategory:CACategoryTeams within:nil];
    return _fetchedResultsController;
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // This is the lame and "slow" way to handle this -- see below for the better way.
    DLog(@"Reloading all");
    [self.tableView reloadData];
}

- (IBAction)toggleChanged:(id)sender
{
    [self updateOkButton];
}

@end
