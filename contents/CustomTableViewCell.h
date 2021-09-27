//
//  CustomTableViewCell.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/11/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *scoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *itemLabel;
@property (weak, nonatomic) IBOutlet UIView *graphBar;
@property (strong, nonatomic) NSString * unReplacedPrompt;


@end
