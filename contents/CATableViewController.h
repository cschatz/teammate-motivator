//
//  CATableViewController.h
//  CoachingApp
//
//  Created by Colin Schatz on 3/20/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface CATableViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Team * currentTeam;

@property (weak, nonatomic) IBOutlet UITextField *addBox;
@property (strong, nonatomic) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderPicker;

@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;

@end
