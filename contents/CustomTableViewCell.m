//
//  CustomTableViewCell.m
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/11/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CustomTableViewCell.h"

@implementation CustomTableViewCell
@synthesize scoreLabel;
@synthesize itemLabel;
@synthesize graphBar;
@synthesize unReplacedPrompt;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
