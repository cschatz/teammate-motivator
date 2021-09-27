//
//  CAQuestionTableViewController.h
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAQuestionTableViewController : UIViewController <UITableViewDelegate, UITableViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSIndexPath * selectedIndexPath;
@property (nonatomic, retain) NSFetchedResultsController * fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSString * addedQuestion;

@end