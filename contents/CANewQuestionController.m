//
//  CANewQuestionController.m
//  TeammateMotivators
//
//  Created by Colin Schatz on 6/27/12.
//  Copyright (c) 2012 Colin G. Schatz. All rights reserved.
//

#import "CANewQuestionController.h"
#import "CAModel.h"
#import "CAQuestionTableViewController.h"

#define kOFFSET_FOR_KEYBOARD 200

@implementation CANewQuestionController
{
    NSArray * _scales;
    CAModel * _model;
    int _whichScale;
    NSMutableArray * _answerChoices;
    int _answerNum;
    CGRect _keyboardRect;
    UIView * _currentTextbox;
    int _nextFocusRow;
    BOOL _keyboardUp;
}

@synthesize tableView = _tableView;
@synthesize questionText = _questionText;
//@synthesize okButton = _okButton;
@synthesize instructionText = _instructionText;
@synthesize saveButton = _saveButton;


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


- (void) viewWillAppear:(BOOL)animated
{
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.toolbarHidden = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _model = [CAModel sharedModel];
    _answerChoices = [NSMutableArray arrayWithObjects: @"", nil];
    _scales = [_model allScales];
    _whichScale = _scales.count;
    self.questionText.placeholder = @"Enter the text for a new question here. Use a * symbol to represent the player's name.";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardAppeared:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardGone)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    _nextFocusRow = -1;
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (@"Answer Choices");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * identifier;
    if (_whichScale < _scales.count)
        identifier = @"AnswerCell";
    else
        identifier = @"NewAnswerCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if (_whichScale < _scales.count)
    {
        Scale * scale = [_scales objectAtIndex:_whichScale];
        AnswerChoice * choice = [[scale answersInDescendingValueOrder] objectAtIndex:indexPath.row];
        cell.textLabel.text = choice.answer;
    }
    else
    {
        UITextField * entrybox = (UITextField *)[cell viewWithTag:1];
        entrybox.tag = 100 * (indexPath.row + 1);
        //NSLog(@"Set tag to %i", 100 * (indexPath.row + 1));
        entrybox.delegate = self;
        entrybox.placeholder = [NSString stringWithFormat:@"Answer #%i (score = %i)", indexPath.row + 1, 5 - indexPath.row];
        if (indexPath.row < _answerChoices.count)
        {
            entrybox.text = [_answerChoices objectAtIndex:indexPath.row];
            cell.hidden = NO;
        }
        else
        {
            cell.hidden = YES;
        }
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void) adjustInstructions
{
    if (_whichScale < _scales.count || _answerChoices.count > 1)
        self.instructionText.hidden = YES;
    else
        self.instructionText.hidden = NO;
    
}

- (void) adjustSaveButton
{
    BOOL complete = YES;
    if ([self.questionText.text isEqualToString:@""])
        complete = NO;
    else if (_whichScale == _scales.count)
    {
        if (_answerChoices.count < 5)
            complete = NO;
        else
        {
            for (NSString * s in _answerChoices)
            {
                if ([s isEqualToString:@""])
                {
                    complete = NO;
                    break;
                }
            }
        }
    }
    self.saveButton.enabled = complete;
}

- (IBAction)goBack:(id)sender
{
    _whichScale = (_whichScale + 1) % (_scales.count + 1);
    [self.tableView reloadData];
    [self adjustInstructions];
    [self adjustSaveButton];
}

- (IBAction)goForward:(id)sender
{
    _whichScale = (_whichScale - 1 + (_scales.count+1)) % (_scales.count + 1);
    [self.tableView reloadData];
    [self adjustInstructions];
    [self adjustSaveButton];
}


- (void)noAvoidance
{    
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.view.frame;
        rect.origin.y = 0;
        self.view.frame = rect;
    }];
}

- (void)updateKeyboardAvoidance:(UIView *)textBox
{
    if (textBox != nil)
        _currentTextbox = textBox;
    // textBox could be either a UITextField or a UITextView
    
    if (_keyboardUp)
    {
        CGRect textfieldRect = [_currentTextbox convertRect:_currentTextbox.frame toView:self.view.window];
        //NSLog(@"Current keyboard rect: %f+%f", _keyboardRect.origin.y, _keyboardRect.size.height);

        float diff = (textfieldRect.origin.y + textfieldRect.size.height) - _keyboardRect.origin.y;
        // NSLog(@"text bottom=%f, keyboard top=%f, diff=%f", textfieldRect.origin.y + textfieldRect.size.height,  _keyboardRect.origin.y, diff);

        CGRect rect = self.view.frame;
        rect.origin.y -= diff;
        if (rect.origin.y > 0)
            rect.origin.y = 0;
        //NSLog(@"Shifting top to %.1f", rect.origin.y);
        [UIView animateWithDuration:0.5 animations:^{
            self.view.frame = rect;
        }];
    }
}

- (void)keyboardGone
{
    [self noAvoidance];
    _keyboardUp = NO;
}

- (void)keyboardAppeared:(NSNotification *)notification
{
    _keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardUp = YES;
    [self updateKeyboardAvoidance:nil];
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self updateKeyboardAvoidance:textView];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"])
    {
        [self.questionText resignFirstResponder];
        self.questionText.text = [self.questionText.text stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
        //self.okButton.hidden = YES;
        [self adjustSaveButton];
        return FALSE;
    }
    else
    {
        return TRUE;
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self adjustSaveButton];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [self adjustSaveButton];
}

// ========== Text Field (answer choices) delegate methods ==========

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //NSLog(@"tag of this textfield: %i", textField.tag);
    int i = (textField.tag / 100) - 1;
    [_answerChoices replaceObjectAtIndex:i withObject:textField.text];
    if (![textField.text isEqualToString:@""] &&
        i == _answerChoices.count-1 && _answerChoices.count < 5)
    {
        [_answerChoices addObject:@""];
        UITableViewCell * nextCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i+1 inSection:0]];
        nextCell.hidden = NO;
        [[nextCell viewWithTag:100*(i+2)] becomeFirstResponder];
    }
    else
    {
        [textField resignFirstResponder];
    }
    [self adjustInstructions];
    [self adjustSaveButton];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self updateKeyboardAvoidance:textField];
}

- (IBAction)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveButtonPressed:(id)sender
{
    DLog(@"Saving new question");
    Scale * theScale;
    if (_whichScale == _scales.count)
    {
        theScale = [_model addScaleWithOrderedAnswerChoicesInArray:
                    [[_answerChoices reverseObjectEnumerator] allObjects]];
    }
    else
    {
        theScale = [_scales objectAtIndex:_whichScale];
    }
    DLog(@"Scale for new question is %@", theScale); 
    [_model addQuestionWithPrompt:self.questionText.text andScale:theScale];
    CAQuestionTableViewController * lastVC = [self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 2)];
    lastVC.addedQuestion = self.questionText.text;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
