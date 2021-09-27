//
//  CAQuestionDetailController.m
//  iCoach
//
//  Created by Colin Schatz on 3/23/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CAQuestionDetailController.h"
#import "CAModel.h"


@implementation CAQuestionDetailController
{
    NSArray * _answerList;
}

@synthesize question = _question;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    _answerList = [self.question answersInDescendingValueOrder];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
        return (@"Question");
    else if (section == 1)
        return (@"Answer Options");
    else
        return (@"Data Collected");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return 1;
    if (section == 1)
        return self.question.scale.choices.count;
    else
        return 1;
}


- (NSString *) getTextForIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return ([self.question.prompt stringByReplacingOccurrencesOfString:@"*" withString:@"____"]);
    }
    else if (indexPath.section == 1)
    {
        return ([[_answerList objectAtIndex:indexPath.row] answer]);
    }
    else
    {
        NSMutableSet * playerSet = [NSMutableSet set];
        for (Rating * r in self.question.relatedRatings)
        {
            [playerSet addObject:(r.playerRated)];
        }
        return ([NSString stringWithFormat: @"%i team members rated, %i ratings total", 
                 playerSet.count, self.question.relatedRatings.count]);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier;
    if (indexPath.section == 0)
        identifier = @"QuestionCell";
    else
        identifier = @"AnswerCell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self getTextForIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * text = [self getTextForIndexPath:indexPath];
    
    // Get a CGSize for the width and, effectively, unlimited height
    CGSize constraint = CGSizeMake(270, 20000.0f);
    // Get the size of the text given the CGSize we just made as a constraint
    CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:constraint lineBreakMode:UILineBreakModeWordWrap];
    // Get the height of our measurement, with a minimum of 44 (standard cell size)
    CGFloat height = size.height;
    // return the height, with a bit of extra padding in
    return (height + 10);
}


#pragma mark - Table view delegate

- (IBAction)deleteButtonPressed:(id)sender
{
    if (self.question.relatedRatings.count > 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Not Allowed" message:@"Sorry, you can't delete a question used for existing ratings." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:@"Really delete this question?" delegate:self cancelButtonTitle:@"Don't Delete" destructiveButtonTitle:@"Delete" otherButtonTitles: nil];
        [sheet showFromTabBar:self.tabBarController.tabBar];   
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.destructiveButtonIndex)
    {
        CAModel * model = [CAModel sharedModel];
        [model deleteObject:self.question];
        [model saveContext];
        DLog(@"Deleted question");   
        [self.navigationController popViewControllerAnimated:YES];
    }
}
@end
