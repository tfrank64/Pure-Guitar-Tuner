//
//  MainViewController.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "MainViewController.h"
#import "FlipsideViewController.h"
#import "KeyHelper.h"
#import "RIOInterface.h"

@interface MainViewController ()
@end

@implementation MainViewController
{
    UIButton *m_toggleButton;
}

@synthesize scrollView = m_scrollView;
@synthesize currentPitchLabel = m_currentPitchLabel;
@synthesize rioRef = m_rioRef;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_rioRef = [RIOInterface sharedInstance];
    
    m_scrollView = [[UIScrollView alloc] init];
    m_scrollView.frame = CGRectMake(0, 22, self.view.bounds.size.width, self.view.bounds.size.height/2);
    m_scrollView.contentSize = CGSizeMake(m_scrollView.frame.size.width * 4, m_scrollView.frame.size.height);

    m_scrollView.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
    m_scrollView.showsVerticalScrollIndicator = NO;
    m_scrollView.showsHorizontalScrollIndicator = NO;
    m_scrollView.scrollEnabled = YES;
    // m_scrollView.userInteractionEnabled = NO;
    
    // Generate content for our scroll view using the frame height and width as the reference point
    int i = 1;
    int decibal = -25;
    while (i<=11)
    {
        UIView *views = [[UIView alloc] initWithFrame:CGRectMake((m_scrollView.frame.size.width/3 * i), 0, 1, m_scrollView.frame.size.height/2)];
        UILabel *tunerNumber = [[UILabel alloc] initWithFrame:CGRectMake((m_scrollView.frame.size.width/3 * i)+5, 0, 100, 20)];

        tunerNumber.text = [NSString stringWithFormat:@"%d", decibal];
        NSLog(@"spacing: %f", m_scrollView.frame.size.width/3 * i);
        views.backgroundColor=[UIColor colorWithRed:0 green:172.0/255.0 blue:221.0/255.0 alpha:1];
        tunerNumber.textColor = [UIColor whiteColor];
        [views setTag:i];
        [m_scrollView addSubview:views];
        [m_scrollView addSubview:tunerNumber];
        decibal += 5;
        i++;
    }
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(m_scrollView.frame.size.width/2, 22, 1, m_scrollView.frame.size.height)];
    lineView.backgroundColor = [UIColor yellowColor];
    
    [self.view addSubview:m_scrollView];
    [self.view insertSubview:lineView aboveSubview:m_scrollView];
    
    m_toggleButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect buttonRect = m_toggleButton.frame;
    buttonRect.origin.x = self.view.frame.size.width-buttonRect.size.width - 8;
    buttonRect.origin.y = buttonRect.size.height + 4;
    m_toggleButton.frame = buttonRect;
    
    [m_toggleButton addTarget:self action:@selector(togglePopover:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:m_toggleButton];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startListener];
    
    // Point is at middle of screen, subtract 160 to get to desired point (eg. 640 is middle, but 480 is exact middle)
    [m_scrollView setContentOffset:CGPointMake(480, 0) animated:YES];
    
    m_currentPitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 200, 44)];
    m_currentPitchLabel.text = @"0.0";
    m_currentPitchLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_currentPitchLabel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [m_rioRef stopListening];
    m_currentPitchLabel = nil;
    [super viewDidDisappear:animated];
}

- (void)startListener
{
    [m_rioRef startListening:self];
}

// This method gets called by the rendering function. Update the UI with
// the character type and store it in our string.
- (void)frequencyChangedWithValue:(float)newFrequency
{
	self.currentFrequency = newFrequency;
	[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
	
	/*
	 * If you want to display letter values for pitches, uncomment this code and
	 * add your frequency to pitch mappings in KeyHelper.m
	 */
	
	
	/*KeyHelper *helper = [KeyHelper sharedInstance];
	NSString *closestChar = [helper closestCharForFrequency:newFrequency];
	
	// If the new sample has the same frequency as the last one, we should ignore
	// it. This is a pretty inefficient way of doing comparisons, but it works.
	if (![self.prevChar isEqualToString:closestChar])
    {
		self.prevChar = closestChar;
		if ([closestChar isEqualToString:@"0"])
        {
            //	[self toggleListening:nil];
		}
		[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
		NSString *appendedString = [self.key stringByAppendingString:closestChar];
		self.key = [NSMutableString stringWithString:appendedString];
        NSLog(@"Current Key: %@", self.key);
	}*/
}

- (void)updateFrequencyLabel
{
	self.currentPitchLabel.text = [NSString stringWithFormat:@"%f", self.currentFrequency];
	[self.currentPitchLabel setNeedsDisplay];
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        [self dismissViewControllerAnimated:YES completion:nil];
    else
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)togglePopover:(id)sender
{
    if (self.flipsidePopoverController)
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
    else
    {
        FlipsideViewController *flipSideViewController = [[FlipsideViewController alloc] init];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:flipSideViewController];
            popoverController.popoverContentSize = CGSizeMake(444, 425);
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
            [popoverController presentPopoverFromRect:m_toggleButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            FlipsideViewController *flipSideViewController = [[FlipsideViewController alloc] init];
            [self presentViewController:flipSideViewController animated:YES completion:nil];
        }
    }
}

@end
