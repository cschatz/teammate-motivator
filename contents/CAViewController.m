#import "CAViewController.h"
#import "CAModel.h"

@interface CAViewController()
- (void) clearStartScreen;
@end

@implementation CAViewController
@synthesize passwordBox = _passwordBox;
@synthesize  greenField = _greenField;
@synthesize unlockMsg = _unlockMsg;

static double RandomNum(double low, double high);

double RandomNum(double low, double high)
{
    double frac = rand()%1001 / 1000;
    return (low + (high - low)*frac);
}


- (void)viewDidLoad {
    [super viewDidLoad];    
    
    UITapGestureRecognizer * tapRecognizer = 
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkPasswd)];
    
    [self.greenField addGestureRecognizer:tapRecognizer];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    /*
    if (!self.timer)
    {
        self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    }
     */
    // force model to load while still on start screen
    [[CAModel sharedModel] coachPassword];
}

- (void)viewDidAppear:(BOOL)animated
{
    // TESTING ONLY
    // [self clearStartScreen];
}

- (void) clearStartScreen
{
    //[self.timer invalidate];
    [self.greenField removeFromSuperview];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [self performSegueWithIdentifier:@"initialSegue" sender:self];
}

- (void) restoreStartScreen
{
    [self.view addSubview:self.greenField];
   // self.timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(moveBall) userInfo:nil repeats:YES];
   // [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];

}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    DLog(@"textFieldShouldReturn");
    if ([textField.text isEqualToString:[[CAModel sharedModel] coachPassword]])
    {
        DLog(@"Password is correct - clearing start screen");
        [self clearStartScreen];
    }
    else
    {
        NSLog(@"Invalid password '%@', checking backup", textField.text);
        if ([[CAModel sharedModel] checkBackupPassword:textField.text])
        {
            NSLog(@"Backup password validated");
            [[[UIAlertView alloc]
              initWithTitle: @"Password Reset"
              message: @"Your reset code was recognized. The password has been reset to the default."
              delegate: nil
              cancelButtonTitle:@"OK"
              otherButtonTitles:nil] show];
        }
        else
        {
            NSLog(@"Backup password no match");
        }
    }
    self.passwordBox.hidden = YES;
    self.unlockMsg.hidden = NO;
    textField.text = @"";
    [textField resignFirstResponder];
    self.passwordHint.hidden = YES;
    return YES;
}


- (void) checkPasswd
{
    self.passwordBox.hidden = NO;
    self.unlockMsg.hidden = YES;
    [self.passwordBox becomeFirstResponder];
    if ([[[CAModel sharedModel] coachPassword] isEqualToString:@"password"])
    {
        self.passwordHint.hidden = NO;
    }
    else
    {
        self.passwordHint.hidden = YES;
    }
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
