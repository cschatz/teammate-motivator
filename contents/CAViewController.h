//
//  MonstersViewController.h
//  Monsters
//
//  Created by Colin Schatz on 2/16/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAViewController : UIViewController <UIGestureRecognizerDelegate, UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UIView *greenField;
@property (strong, nonatomic) IBOutlet UITextField *passwordBox;

@property (weak, nonatomic) IBOutlet UILabel *passwordHint;


@property (strong, nonatomic) IBOutlet UILabel *unlockMsg;
- (void) restoreStartScreen;

@end
