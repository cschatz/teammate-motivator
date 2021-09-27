//
//  CAQuestionSelectController.m
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAQuestionSelectController.h"
#include "CAModel.h"

@implementation CAQuestionSelectController
{
    CAModel * _model;
}

@synthesize itemCountLabel = _itemCountLabel;
@synthesize beginAssessmentsButton = _beginAssessmentsButton;
@synthesize tableView = _tableView;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [CAModel sharedModel];
    self.navigationItem.hidesBackButton = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
}


- (void)viewDidUnload
{
    [self setItemCountLabel:nil];
    [self setBeginAssessmentsButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int n = [tableView indexPathsForSelectedRows].count;
    self.itemCountLabel.text = [NSString stringWithFormat:@"%i", n];
    if (n == 1)
        self.beginAssessmentsButton.hidden = NO;
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int n = [tableView indexPathsForSelectedRows].count;
    self.itemCountLabel.text = [NSString stringWithFormat:@"%i", n];
    if (n == 0)
        self.beginAssessmentsButton.hidden = YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // only one segue so far - otherwise need to put an if() in here
    for (NSIndexPath * indexPath in [self.tableView indexPathsForSelectedRows])
    {
        [_model includeQuestion:[self.fetchedResultsController objectAtIndexPath:indexPath]];
    }
}

- (IBAction)cancelAssessment:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
