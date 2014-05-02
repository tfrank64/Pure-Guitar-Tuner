//
//  MainViewController.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "MainViewController.h"
#import "EFCircularSlider.h"
#import "FlipsideViewController.h"
#import "KeyHelper.h"
#import "MacroHelpers.h"

//#define DSharp  330.5
//#define D5      318.5
//#define CSharp5 306.5
//#define C5      294.5
//#define B4      282.5
//#define ASharp4 270.5
//#define A4      258.5
//#define GSharp4 246.5
//#define G4      234.5
#define FSharp4 370.0
#define F4      349.2
#define E4      329.6
#define DSharp4 311.1
#define D4      293.7
#define CSharp4 277.2
#define C4      261.6
#define B3      246.9
#define ASharp3 233.1
#define A3      220.0
#define GSharp3 207.7
#define G3      196.0
#define FSharp3 185.0
#define F3      174.6
#define E3      164.8
#define DSharp3 155.6
#define D3      146.8
#define CSharp3 138.6
#define C3      130.8
#define B2      123.5
#define ASharp2 116.5
#define A2      110.0
#define GSharp2 103.8
#define G2      98.0
#define FSharp2 92.50
#define F2      87.31
#define E2      82.41


@interface MainViewController ()
@end

@implementation MainViewController
{
    int count;
    UIButton *m_toggleButton;
}

@synthesize currentPitchLabel = m_currentPitchLabel;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = rgb(36, 42, 50);
    
    count = 0;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:4096 forKey:@"kBufferSize"];
    [userDefaults setInteger:0 forKey:@"percentageOfOverlap"];
    [userDefaults synchronize];
    
    CGRect currentFrame = self.view.frame;
    self.knobPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(currentFrame.size.width/6, currentFrame.size.width/5, currentFrame.size.width/1.5, currentFrame.size.width/1.5)];
    //self.knobPlaceholder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.knobPlaceholder];
    self.knobControl = [[RWKnobControl alloc] initWithFrame:self.knobPlaceholder.bounds];
    [self.knobPlaceholder addSubview:_knobControl];
    
    self.knobControl.lineWidth = 8.0;
    self.knobControl.pointerLength = 8.0;
    self.knobControl.tintColor = [UIColor colorWithRed:0.237 green:0.504 blue:1.000 alpha:1.000];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, currentFrame.size.height/1.33, currentFrame.size.width, currentFrame.size.height/4)];
    _scrollView.contentSize = CGSizeMake(currentFrame.size.width * 4, currentFrame.size.height/4);
    _scrollView.backgroundColor = [UIColor lightGrayColor];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    int i = 0;
    while (i <= 3)
    {
        UIView *views = [[UIView alloc] initWithFrame:CGRectMake(((_scrollView.frame.size.width)*i)+20, 10, (_scrollView.frame.size.width)-40, _scrollView.frame.size.height-20)];
        views.backgroundColor=[UIColor yellowColor];
        [views setTag:i];
        [_scrollView addSubview:views];
        i++;
    }
    
    _pitchDetector = [PitchDetector sharedDetector];
    [_pitchDetector TurnOnMicrophoneTuner:self];
    
    /*m_scrollView = [[UIScrollView alloc] init];
    m_scrollView.frame = CGRectMake(0, 22, self.view.bounds.size.width, self.view.bounds.size.height/2);
    m_scrollView.contentSize = CGSizeMake(m_scrollView.frame.size.width * 4, m_scrollView.frame.size.height);
    
    m_scrollView.backgroundColor = rgb(36, 42, 50);
    m_scrollView.showsVerticalScrollIndicator = NO;
    m_scrollView.showsHorizontalScrollIndicator = NO;
    m_scrollView.scrollEnabled = YES;
     m_scrollView.userInteractionEnabled = NO;
    
    // Generate content for our scroll view using the frame height and width as the reference point
    int i = 1;
    int decibal = -25;
    while (i<=11)
    {
        UIView *views = [[UIView alloc] initWithFrame:CGRectMake((m_scrollView.frame.size.width/3 * i), 0, 1, m_scrollView.frame.size.height/2)];
        UILabel *tunerNumber = [[UILabel alloc] initWithFrame:CGRectMake((m_scrollView.frame.size.width/3 * i)+5, 0, 100, 20)];

        tunerNumber.text = [NSString stringWithFormat:@"%d", decibal];
        //NSLog(@"spacing: %f", m_scrollView.frame.size.width/3 * i);
        views.backgroundColor = rgb(0, 172, 221);
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
    [self.view insertSubview:lineView aboveSubview:m_scrollView];*/
    
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
    // Point is at middle of screen, subtract 160 to get to desired point (eg. 640 is middle, but 480 is exact middle)
    // [m_scrollView setContentOffset:CGPointMake(480, 0) animated:YES];
    
    m_currentPitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 300, 200, 44)];
    m_currentPitchLabel.text = @"0.0";
    m_currentPitchLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_currentPitchLabel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    m_currentPitchLabel = nil;
    [super viewDidDisappear:animated];
}

- (void)updateFrequencyLabel
{
    count++;
    if (count >= 20 && self.currentFrequency <= 500.0) // Keeps tuner view from going crazy
    {
        //int page = _scrollView.contentOffset.x / _scrollView.frame.size.width;
        // update current note if in range
        // update ui of freqency within range
        CGFloat randomValue = (arc4random() % 101) / 100.f;
        [self.knobControl setValue:randomValue animated:YES];
        //[m_scrollView setContentOffset:CGPointMake(self.currentFrequency, 0) animated:YES];
        count = 0;
    }
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

- (int)calculateCurrentNote:(double)freqency
{
 
    return 0;
}

- (void)updateToFrequncy:(double)freqency
{
    //NSLog(@"CurrentFrequency: %f", freqency);
    self.currentFrequency = freqency;
    [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
}

- (void)dealloc
{
    [self.pitchDetector TurnOffMicrophone];
}

@end
