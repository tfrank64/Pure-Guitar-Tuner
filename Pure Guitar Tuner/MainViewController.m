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
#import "MacroHelpers.h"

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
    _noteData = [[GTNote alloc] init];
    
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
    if (count >= 20 && _noteData.currentFrequency <= 500.0) // Keeps tuner view from going crazy
    {
        //int page = _scrollView.contentOffset.x / _scrollView.frame.size.width;
        // update current note if in range
        // update ui of freqency within range
        CGFloat randomValue = (arc4random() % 101) / 100.f;
        [self.knobControl setValue:randomValue animated:YES];
        //[m_scrollView setContentOffset:CGPointMake(self.currentFrequency, 0) animated:YES];
        count = 0;
    }
	self.currentPitchLabel.text = [NSString stringWithFormat:@"%f  note: %@", _noteData.currentFrequency, _noteData.currentNote];
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

- (void)updateToFrequncy:(double)freqency
{
    //NSLog(@"CurrentFrequency: %f", freqency);
    [_noteData calculateCurrentNote:freqency];
    [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
}

- (void)dealloc
{
    [self.pitchDetector TurnOffMicrophone];
}

@end
