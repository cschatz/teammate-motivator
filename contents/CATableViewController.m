
#import "CATableViewController.h"
#import "CAPrepViewController.h"
#import "CAModel.h"

@implementation CATableViewController
{
    NSString * _newPlayerGender;
    NSIndexPath * _currentIndexPath;
    Team * _teamToDelete;
    CAModel * _model;
    NSMutableArray * _addedPlayers;
}

@synthesize currentTeam = _currentTeam;
@synthesize addBox = _addBox;
@synthesize theTable = _theTable;
@synthesize genderPicker = _genderPicker;
@synthesize fetchedResultsController = _fetchedResultsController;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)hideKeyboard
{
    [self.addBox resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _model = [CAModel sharedModel];
    
    _addedPlayers = [NSMutableArray array];
    
    _newPlayerGender = @"m";    
    self.navigationItem.rightBarButtonItem = [self editButtonItem];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;  // don't "block" touches
    [self.view addGestureRecognizer:gestureRecognizer];
    
    DLog(@"Loaded, team is %@", self.currentTeam);
}

- (void)viewDidUnload
{
    [self setTheTable:nil];
    [self setAddBox:nil];
    [self setGenderPicker:nil];
    [super viewDidUnload];
    self.fetchedResultsController = nil;
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int n = [[[_fetchedResultsController sections] objectAtIndex:section] numberOfObjects];    
    if (self.editing || ![self.navigationItem.title isEqualToString:@"Teams"])
    {
        n = n + 1;
    }
    return (n);
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath 
{
    int adj;
    
    if ([self.navigationItem.title isEqualToString:@"Teams"])
        adj = (self.editing) ? 1 : 0;
    else
        adj = 1;
    
    indexPath = [NSIndexPath indexPathForRow:(indexPath.row-adj) inSection:indexPath.section];
    
    if ([self.navigationItem.title isEqualToString:@"Teams"])
    {
        if (!adj || indexPath.row >= 0)
        {
            Team * team = [_fetchedResultsController objectAtIndexPath:indexPath];  
            cell.textLabel.text = team.name;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%i %s", team.members.count, ((team.members.count == 1)?"member":"members")];
        }
    }
    else // displaying PLAYERS
    {
        if (!adj || indexPath.row >= 0)
        {
            Player * player = [_fetchedResultsController objectAtIndexPath:indexPath];
            cell.textLabel.text = player.fullname;
            cell.detailTextLabel.text = @"scores";
            //cell.detailTextLabel.text = player.gender;            
        }
        else if (!self.editing)
        {
            cell.textLabel.text = @"(All team members)";
            cell.detailTextLabel.text = @"team summary";
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *CellIdentifier;
    if (self.editing && indexPath.row == 0)
    {
        if ([self.navigationItem.title isEqualToString:@"Teams"])
            CellIdentifier = @"FillableTeam";
        else
            CellIdentifier = @"FillablePlayer";
    }
    else
    {
        CellIdentifier = @"Cell";
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    [self configureCell:cell atIndexPath:indexPath];

    
    if (self.editing && indexPath.row == 0 )
    {
        self.genderPicker = (UISegmentedControl *)[cell viewWithTag:23];
        self.addBox = (UITextField *)[cell viewWithTag:42];
        [self.genderPicker setSelectedSegmentIndex:([_newPlayerGender isEqualToString:@"m"] ? 0 : 1)];
    }
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing && indexPath.row == 0)
        return UITableViewCellEditingStyleInsert;
    else
        return UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing && indexPath.row == 0 && ![self.navigationItem.title isEqualToString:@"Teams"])
        return 84;
    else
        return 44;
}


- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        DLog(@"CANCEL");
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:_currentIndexPath]
                     withRowAnimation:UITableViewRowAnimationFade];
    }
    else
    {
        DLog(@"Team being deleted: %@", _teamToDelete.name);
        NSManagedObjectContext * context = self.fetchedResultsController.managedObjectContext;
        [context deleteObject:_teamToDelete];
        [_model saveContext];        
        DLog(@"Deleted team");
    }
}

// internal helper method
- (void)errorAlertWithTitle:(NSString *)title andMessage:(NSString *)msg
{
    [[[UIAlertView alloc]
      initWithTitle: title
      message: msg
      delegate: nil
      cancelButtonTitle:@"OK"
      otherButtonTitles:nil] show];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DLog(@"commit edit");
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        _currentIndexPath = indexPath;
        indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
        if ([self.navigationItem.title isEqualToString:@"Teams"])
        {
            _teamToDelete = [_fetchedResultsController objectAtIndexPath:indexPath];  
            
            NSString * prompt = [NSString stringWithFormat:@"Delete team '%@'\nAND ALL MEMBERS of %@?", _teamToDelete.name, _teamToDelete.name];
            UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:prompt delegate:self cancelButtonTitle:@"Don't Delete" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
            [sheet showFromTabBar:self.tabBarController.tabBar];          
        }
        else
        {
            [self.fetchedResultsController.managedObjectContext deleteObject:[_fetchedResultsController objectAtIndexPath:indexPath]];
            [_model saveContext];
            DLog(@"Deleted player");
        }
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) 
    {
        NSMutableString * newName = [NSMutableString stringWithString:self.addBox.text];
        DLog(@"At time of commit, text box contains '%@'", self.addBox.text);
        // remove leading spaces
        while (newName.length > 0 && [[newName substringToIndex:1] isEqualToString:@" "])
            [newName deleteCharactersInRange:NSMakeRange(0, 1)];
        // remove trailing spaces
        while (newName.length > 0 && [[newName substringFromIndex:(newName.length-1)] isEqualToString:@" "])
            [newName deleteCharactersInRange:NSMakeRange(newName.length-1, 1)];
        // compress non-single spaces
        while ([newName replaceOccurrencesOfString:@"  " withString:@" " options:NSLiteralSearch range:NSMakeRange(0, newName.length)] > 0)
            /* nothing in loop body */ ;
            
        DLog(@"After space trimming: '%@'", newName);
        if (![newName isEqualToString:@""])
        {
            if ([self.navigationItem.title isEqualToString:@"Teams"])
            {
                if ([_model teamExists:newName])
                {
                    [self errorAlertWithTitle:@"Duplicate Name" andMessage:
                        [NSString stringWithFormat:@"There is already a team named %@.",
                         newName]];
                }
                else
                {
                    DLog(@"Adding team %@", newName);
                    [_model addTeam:newName];
                }
            }
            else
            {
                if ([[_model playersOnNamedTeam:self.navigationItem.title] containsObject:newName])
                {
                    [self errorAlertWithTitle:@"Duplicate Name" andMessage:
                        [NSString stringWithFormat:@"There is already a player named %@ on %@.",
                         newName, self.navigationItem.title]];
                }
                else if ([newName rangeOfString:@" "].location == NSNotFound)
                {
                    [self errorAlertWithTitle:@"Name Is Too Short" andMessage:
                        [NSString stringWithFormat:@"Each player needs at least a first and last name."]];
                }
                else
                {
                    DLog(@"Adding %@ (%@) to team", newName, _newPlayerGender);
                    [_model addPlayer:newName withGender:_newPlayerGender toTeam:self.navigationItem.title];
                } 
            }
            _addBox.text = @"";
        }
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DLog(@"Prepping for segue, team is %@", self.currentTeam);
    if ([segue.identifier isEqualToString:@"detailPrepSegue"])
    {
        Player * who;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:_currentIndexPath.row-1 inSection:_currentIndexPath.section];
        if (indexPath.row < 0)
        {
            DLog(@"Negative row number");
            who = nil;
        }
        else
        {
            DLog(@"normal row number %i", indexPath.row);
            who = [_fetchedResultsController objectAtIndexPath:indexPath];
        }
        ((CAPrepViewController*)segue.destinationViewController).whichTeam = self.currentTeam;
        ((CAPrepViewController*)segue.destinationViewController).whichPlayer = who;
    }
    else
    {
        ((CATableViewController*)segue.destinationViewController).navigationItem.title = [self.currentTeam name];
        ((CATableViewController*)segue.destinationViewController).currentTeam = self.currentTeam;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _currentIndexPath = indexPath;
    if ([self.navigationItem.title isEqualToString:@"Teams"])
    {
        self.currentTeam = (Team *)[_fetchedResultsController objectAtIndexPath:indexPath];
        [self performSegueWithIdentifier:@"recursiveSegue" sender:nil];
    }
    else
    {
        [self performSegueWithIdentifier:@"detailPrepSegue" sender:nil];
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.theTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"shouldreturn?");
    [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleInsert forRowAtIndexPath:[NSIndexPath indexPathWithIndex:0]];
    [textField becomeFirstResponder];
    return NO;
}

                 
- (IBAction)genderSelected:(UISegmentedControl *)sender 
{
    _newPlayerGender = [[[sender titleForSegmentAtIndex:sender.selectedSegmentIndex] lowercaseString] substringToIndex:1];
    DLog(@"Gender set to %@", _newPlayerGender);
}


- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) 
    {
        return _fetchedResultsController;
    }
    if ([self.navigationItem.title isEqualToString:@"Teams"])
    {
        _fetchedResultsController = [_model fetchedResultsControllerForCategory:CACategoryTeams within:nil];
    }
    else
    {
        _fetchedResultsController = [_model fetchedResultsControllerForCategory:CACategoryPlayers within:self.navigationItem.title];
    }            
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // This is the lame/slow way to handle this (though probably fast enough?)
    // Better way below.
    DLog(@"Reloading all");
    [self.tableView reloadData];
    DLog(@"Reloaded");
}


/*
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
          
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}*/



@end
