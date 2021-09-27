//
//  CADetailViewController.h
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Player.h"

@interface CAAttendanceDataController : UIViewController <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) Player * whichPlayer;
@property (strong, nonatomic) Team * whichTeam;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
