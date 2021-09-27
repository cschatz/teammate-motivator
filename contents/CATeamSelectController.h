//
//  CATeamSelectController.h
//  iCoach
//
//  Created by Colin Schatz on 3/24/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAModel.h"

@interface CATeamSelectController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, readonly, nonatomic) CAModel * model;

@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *peerRatingControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *coachRatingControl;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end
