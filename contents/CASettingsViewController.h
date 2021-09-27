//
//  CASettingsViewController.h
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/7/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CASettingsViewController : UIViewController <UIActionSheetDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *reportLabel;

@property (weak, nonatomic) IBOutlet UITextField *userCurrent;
@property (weak, nonatomic) IBOutlet UITextField *userNew;
@property (weak, nonatomic) IBOutlet UITextField *userConfirmNew;
@property (weak, nonatomic) IBOutlet UILabel *waitLabel;

@end
