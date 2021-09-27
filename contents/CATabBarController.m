//
//  CATabBarController.m
//  CoachingApp
//
//  Created by Colin Schatz on 3/19/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CATabBarController.h"
#import "CAModel.h"

@implementation CATabBarController


#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
/*
    UIViewController * c1 = 
    [self.viewControllers objectAtIndex:0];
    c1.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFavorites tag:0];
    NSArray *arr = [NSArray arrayWithObjects: c1, nil];
    self.viewControllers = arr;
 */
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)viewDidAppear:(BOOL)animated
{
    if ([[[CAModel sharedModel] coachPassword] isEqualToString:@"password"])
    {
        [[[UIAlertView alloc]
          initWithTitle: @"Change Your Password"
          message: @"Select the Settings tab below to change the coach/manager's password."
          delegate: nil
          cancelButtonTitle:@"OK"
          otherButtonTitles:nil] show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
