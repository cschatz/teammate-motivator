//
//  CASettingsViewController.m
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/7/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CASettingsViewController.h"
#import "CAViewController.h"
#import "CAModel.h"

@implementation CASettingsViewController
@synthesize reportLabel;
@synthesize userCurrent;
@synthesize userNew;
@synthesize userConfirmNew;
@synthesize waitLabel;

- (IBAction)userWantsToChangePassword 
{
    NSString * title;
    NSString * msg;
    if ([self.userCurrent.text isEqualToString:[[CAModel sharedModel] coachPassword]])
    {
        if ([self.userNew.text isEqualToString:self.userConfirmNew.text])
        {
            [[NSUserDefaults standardUserDefaults] setObject:self.userNew.text forKey:@"coachpw"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            title = @"Success";
            msg = @"The coach/manager's password has been changed.";
        }
        else
        {
            title = @"Mismatch";
            msg = @"The two new password entries do not match. Try again.";
        }
    }
    else
    {
        title = @"Wrong Password";
        msg = @"You did not enter the correct current password. Try again.";
    }
    
    
    [self.userCurrent resignFirstResponder];
    [self.userNew resignFirstResponder];
    [self.userConfirmNew resignFirstResponder];
    
    self.userCurrent.text = @"";
    self.userNew.text = @"";
    self.userConfirmNew.text = @"";
     
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title                                                                  
                                                    message:msg
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (IBAction)resetRequested
{
    UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Resetting Teammate Motivator will remove all data you have gathered and restore the app to its default contents. Do you really want to reset ALL DATA?"
                                                        delegate:self cancelButtonTitle:@"Don't Reset" destructiveButtonTitle:@"Reset" otherButtonTitles: nil];
    [sheet showFromTabBar:self.tabBarController.tabBar];  
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void)viewWillAppear:(BOOL)animated
{
    self.reportLabel.hidden = YES;
}

- (void)viewDidUnload
{
    [self setReportLabel:nil];
    [self setUserCurrent:nil];
    [self setUserNew:nil];
    [self setUserConfirmNew:nil];
    [self setWaitLabel:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        self.waitLabel.hidden = NO;
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        DLog(@"RESET");
        self.waitLabel.hidden = NO;
        [[CAModel sharedModel] resetToDefaults];
        DLog(@"RESET complete");
        self.reportLabel.hidden = NO;
        self.waitLabel.hidden = YES;
    } 
}

- (IBAction)lockScreenRequested:(id)sender
{
    CAViewController * orig = (CAViewController *)self.navigationController.tabBarController.presentingViewController;
    [self.navigationController popToRootViewControllerAnimated:YES];
    [orig restoreStartScreen];
    [orig dismissModalViewControllerAnimated:YES];
    return;
}

@end
