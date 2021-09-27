//
//  CAAttendanceController.h
//  iCoach
//
//  Created by Colin Schatz on 3/25/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Team.h"

@interface CAAttendanceController : UIViewController
   <UITableViewDelegate, UITableViewDelegate>

@property (strong) Team * whichTeam;
@property (strong, nonatomic) IBOutlet UILabel *presentCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end
