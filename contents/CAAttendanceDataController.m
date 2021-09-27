//
//  CADetailViewController.m
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAAttendanceDataController.h"
#import "CAModel.h"

@implementation CAAttendanceDataController
{
    CAModel * _model;
    NSDateFormatter * _stdDateFormatter;
}
@synthesize whichPlayer = _whichPlayer;
@synthesize whichTeam = _whichTeam;

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [CAModel sharedModel];
    _stdDateFormatter = [[NSDateFormatter alloc] init];
    [_stdDateFormatter setDateFormat:@"E M/d/yy"];
    if (_whichPlayer == nil)
        self.navigationItem.title = _whichTeam.name;
    else
        self.navigationItem.title = _whichPlayer.fullname;
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_model numDaysWithAttendanceData];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int N = [_model numDaysWithAttendanceData] - 1;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AttendanceDataCell"];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AttendanceDataCell"];
    }
    
    cell.textLabel.text = [_stdDateFormatter stringFromDate: [_model dateForDayIndex:(N-indexPath.row)]];
    
    
    if (_whichPlayer == nil)
    {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ present",
                MaybePlural(@"team member", [_model numPlayersPresentForDayIndex:(N-indexPath.row)])
                                     ];
    }
    else
    {
        if ([_model wasPlayer:_whichPlayer presentOnDayIndex:(N-indexPath.row)])
        {
            cell.detailTextLabel.text = @"present";
            cell.detailTextLabel.textColor = [UIColor darkGrayColor];
        }
        else
        {
            cell.detailTextLabel.text = @"ABSENT";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
    }
    return cell;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}


@end
