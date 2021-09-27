//
//  CAQuestionSelectController.h
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CAQuestionTableViewController.h"

@interface CAQuestionSelectController : CAQuestionTableViewController

@property (strong, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (strong, nonatomic) IBOutlet UIButton *beginAssessmentsButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
