
#import "GraphViewController.h"
#import "CAModel.h"

@interface GraphViewController ()


@end


@implementation GraphViewController

@synthesize mainTitle = _mainTitle;
@synthesize subTitle = _subTitle;
@synthesize barGraph = _barGraph;
@synthesize scrollView = _scrollView;
@synthesize whichTeam = _whichTeam, whichPlayer = _whichPlayer, whichQuestion = _whichQuestion;

- (void)viewDidLoad
{
    self.barGraph.minX = 1;
    self.barGraph.maxX = 5;
    self.barGraph.xTickSpacing = 1;
    
    if (_whichTeam == nil)
    {
        self.subTitle.text = [_whichQuestion stringByReplacingOccurrencesOfString:@"*" withString:_whichPlayer];
        
        if ([CAModel sharedModel].resultsFilter == ResultsUsePeerRatingsOnly)
            self.mainTitle.text = @"Average Score Given By Teammates";
        else
            self.mainTitle.text = @"Score Given By Coach/Manager";
        
        NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MMM d"];
        
        NSArray * dates = [[CAModel sharedModel] daySequenceForPrompt:_whichQuestion];
        NSArray * avgs = [[CAModel sharedModel] averageSequenceForPrompt:_whichQuestion];

        assert(dates.count == avgs.count);
        
        for (int i = 0; i < dates.count; i++)
        {
            [self.barGraph addBarWithLabel:[formatter stringFromDate:[dates objectAtIndex:i]]
                                  andValue:[[avgs objectAtIndex:i] doubleValue]
             ];
        }
    }
    else
    {
        self.subTitle.text = [_whichQuestion stringByReplacingOccurrencesOfString:@"*" withString:@"____"];
        
        if ([CAModel sharedModel].resultsFilter == ResultsUsePeerRatingsOnly)
            self.mainTitle.text = @"Average of Last 3 Peer Ratings";
        else
            self.mainTitle.text = @"Average of Last 3 Coach/Manager Ratings";
            
        NSDictionary * map = [[CAModel sharedModel] playerToAvgMap];
        for (NSString * p in [[map allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)])
        {
            [self.barGraph addBarWithLabel:p andValue:[[map objectForKey:p] doubleValue]];
        }
    }
    [self.barGraph doneAddingData];
    
    // "autosize" the scroll view
    //float tabBarHeight = self.tabBarController.tabBar.bounds.size.height;
    float scrollViewTop = self.scrollView.frame.origin.y;
    float overallHeight = self.view.bounds.size.height - self.mainTitle.bounds.size.height;
    
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.size.height = overallHeight-scrollViewTop;
    self.scrollView.frame = scrollFrame;
    
    // fix the graph enclosure size
    CGRect encRect = self.graphEnclosure.frame;
    encRect.size.height = self.barGraph.frame.size.height
                /* + self.mainTitle.frame.size.height - 10 */;
    self.graphEnclosure.frame = encRect;
    
    // move the graph to the top of the enclosure
    //CGRect graphRect = self.barGraph.frame;
    //graphRect.origin.y = 0;
    //self.barGraph.frame = graphRect;
    
    // move the mainTitle (x-axis label) and Done button to immediately below the graph
    CGRect titleRect = self.mainTitle.frame;
    CGRect buttonRect = self.doneButton.frame;
    
    int encBottom = scrollViewTop + encRect.size.height;
    int scrollBottom = scrollViewTop + scrollFrame.size.height;
    int minBottom = MIN(encBottom, scrollBottom);
    
    titleRect.origin.y = minBottom;
    buttonRect.origin.y = minBottom;
    
    self.mainTitle.frame = titleRect;
    self.doneButton.frame = buttonRect;
    
    // scroll size is the entire graph enclosure
    self.scrollView.contentSize = self.graphEnclosure.frame.size;
    
    // allow zooming only if graph doesn't fit within scroll view "window"
    if (encRect.size.height > self.scrollView.bounds.size.height)
    {
        self.scrollView.minimumZoomScale =  self.scrollView.bounds.size.height / encRect.size.height;
        // also scroll down to bottom
        [self.scrollView setContentOffset:CGPointMake(0, encRect.size.height - self.scrollView.bounds.size.height) animated:NO];
    }
    else
        self.scrollView.minimumZoomScale = 1;
    
    
    self.scrollView.maximumZoomScale=1;
    self.scrollView.delegate=self;

    [self.navigationController setNavigationBarHidden:YES];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.graphEnclosure;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    float graphw = self.graphEnclosure.frame.size.width;
    float scrollw = scrollView.frame.size.width;
    CGRect gframe = self.graphEnclosure.frame;
    
    if (gframe.size.width < scrollView.frame.size.width)
    {
        self.graphEnclosure.frame = CGRectMake((scrollw-graphw)/2, gframe.origin.y, gframe.size.width, gframe.size.height);
    }
    else
    {
        self.graphEnclosure.frame = CGRectMake(0, gframe.origin.y, gframe.size.width, gframe.size.height);
    }
}

#pragma mark - View lifecycle


- (void)viewDidUnload
{
    [self setScrollView:nil];
    [self setMainTitle:nil];
    [self setSubTitle:nil];
    [self setGraphEnclosure:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO];
}

- (IBAction)userPressedBack:(UIButton *)sender
{
    [self.presentingViewController dismissModalViewControllerAnimated:YES];
}

@end
