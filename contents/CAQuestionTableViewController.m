//
//  CAQuestionTableViewController.m
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAQuestionTableViewController.h"
#import "CAQuestionDetailController.h"
#import "CANewQuestionController.h"
#import "CAModel.h"

@implementation CAQuestionTableViewController
{
    CAModel * _model;    
}
@synthesize selectedIndexPath = _selectedIndexPath;
@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize tableView = _tableView;
@synthesize addedQuestion = _addedQuestion;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [CAModel sharedModel];
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSError *error;
	if (![[self fetchedResultsController] performFetch:&error]) {
		NSLog(@"Unresolved error when fetching %@, %@", error, [error userInfo]);
		abort();
	}
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    DLog(@"Question table view did appear");
    if (_addedQuestion != nil)
    {
        DLog(@"Flash added question '%@'", _addedQuestion);
        int row = 0;
        for (Question * q in [_fetchedResultsController fetchedObjects])
        {
            NSString * prompt = q.prompt;
            DLog(@"  %@", prompt);
            if ([prompt isEqualToString:_addedQuestion])
            {
                DLog(@"** Match!");
                NSIndexPath * indexPath = [NSIndexPath indexPathForRow:row inSection:0];
                [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
                break;
            }
            row++;
        }        
        _addedQuestion = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    _fetchedResultsController = nil;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];    
    if (self.editing)
    {
        n = n + 1;
    }
    DLog(@"Number of questions shown in table: %i", n);
    return (n);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
    int adj = (self.editing) ? 1 : 0;
    
    indexPath = [NSIndexPath indexPathForRow:(indexPath.row-adj) inSection:indexPath.section];
    
    if (!adj || indexPath.row >= 0)
    {
        Question * question = [_fetchedResultsController objectAtIndexPath:indexPath];  
        cell.textLabel.text = [question.prompt stringByReplacingOccurrencesOfString:@"*" withString:@"____"];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BigCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(UITableViewCell*)sender
{
    if ([segue.identifier isEqualToString:@"questionSegue"])
    {
        CAQuestionDetailController * dest = segue.destinationViewController;
        dest.question = [_fetchedResultsController objectAtIndexPath:self.selectedIndexPath];
    }
    else if ([segue.identifier isEqualToString:@"addQuestionSegue"])
    {

    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    [self performSegueWithIdentifier:@"questionSegue" sender:nil];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [_model fetchedResultsControllerForCategory:CACategoryQuestions within:nil];
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    DLog(@"Reloading all");
    [self.tableView reloadData];
    DLog(@"Reloaded");
}


@end
