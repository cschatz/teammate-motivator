//
//  CAQuestionDetailController.h
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface CAQuestionDetailController : UITableViewController <UIActionSheetDelegate>
@property (strong) Question * question;
@end
