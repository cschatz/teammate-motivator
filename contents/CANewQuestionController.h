//
//  CANewQuestionController.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/27/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSTextView.h"

@interface CANewQuestionController : UIViewController
   <UITableViewDelegate, UITableViewDelegate,
UITextViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet SSTextView *questionText;

@property (weak, nonatomic) IBOutlet UILabel *instructionText;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@end
