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
#import "FBKVOController.h"
#import "MacroHelpers.h"

@interface MainViewController ()
@end

@implementation MainViewController
{
    int count;
    UIButton *m_toggleButton;
    FBKVOController *_KVOController;
}

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
    
    m_toggleButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    CGRect buttonRect = m_toggleButton.frame;
    buttonRect.origin.x = self.view.frame.size.width-buttonRect.size.width - 8;
    buttonRect.origin.y = buttonRect.size.height + 4;
    m_toggleButton.frame = buttonRect;
    
    [m_toggleButton addTarget:self action:@selector(togglePopover:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:m_toggleButton];
    
    _noteDisplay = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2.65, self.view.frame.size.width/2.65, 80, 80)];
    [_noteDisplay setText:@"-"];
    [_noteDisplay setTextColor:[UIColor whiteColor]];
    [_noteDisplay setTextAlignment:NSTextAlignmentCenter];
    [_noteDisplay setFont:[UIFont boldSystemFontOfSize:40.0f]];
    //[noteDisplay setBackgroundColor:[UIColor redColor]];
    [self.view addSubview:_noteDisplay];
    
    // Load data components
    _pitchDetector = [PitchDetector sharedDetector];
    [_pitchDetector TurnOnMicrophoneTuner:self];
    _noteData = [[GTNote alloc] init];
    
    _KVOController = [FBKVOController controllerWithObserver:self];
    [_KVOController observe:_noteData keyPath:@"currentNote" options:NSKeyValueObservingOptionNew block:^(MainViewController *observer, GTNote *object, NSDictionary *change) {
        NSLog(@"Changed: %@", change[NSKeyValueChangeNewKey]);
        _noteDisplay.text = object.currentNote;
        [self updateFrequencyLabel];
    }];
    
    [_KVOController observe:_noteData keyPath:@"currentFrequency" options:NSKeyValueObservingOptionNew block:^(MainViewController *observer, GTNote *object, NSDictionary *change) {
        NSLog(@"FreqChange: %@", change[NSKeyValueChangeNewKey]);
        [_freqencyDisplay setText:[NSString stringWithFormat:@"%f", object.currentFrequency]];
        [self updateNote];
    }];
}

- (void)viewDidAppear:(BOOL)animated
{    
    _freqencyDisplay = [[UILabel alloc] initWithFrame:CGRectMake(50, 300, 200, 44)];
    _freqencyDisplay.text = @"0.0";
    _freqencyDisplay.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_freqencyDisplay];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _noteDisplay = nil;
    _freqencyDisplay = nil;
    [super viewDidDisappear:animated];
}

- (void)updateNote
{
    [_noteDisplay setNeedsDisplay];
    [self.freqencyDisplay setNeedsDisplay];
}

- (void)updateFrequencyLabel
{
    count++;
    if (count >= 20 && _noteData.currentFrequency <= 500.0) // Keeps tuner view from going crazy
    {
        //int page = _scrollView.contentOffset.x / _scrollView.frame.size.width;

        CGFloat randomValue = (arc4random() % 101) / 100.f;
        [self.knobControl setValue:randomValue animated:YES];
        count = 0;
    }
	[_freqencyDisplay setNeedsDisplay];
}

- (void)updateToFrequncy:(double)freqency
{
    //NSLog(@"CurrentFrequency: %f", freqency);
    [_noteData calculateCurrentNote:freqency];
    //[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
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

- (void)dealloc
{
    [self.pitchDetector TurnOffMicrophone];
}

@end
