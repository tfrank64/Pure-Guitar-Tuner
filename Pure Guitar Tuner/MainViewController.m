//
//  MainViewController.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "MainViewController.h"
#import "FlipsideViewController.h"
#import "FBKVOController.h"
#import "MacroHelpers.h"

@interface MainViewController ()
@end

@implementation MainViewController
{
    int count;
    UIButton *m_toggleButton;
    FBKVOController *_KVOController;
    NSString *lastFreq;
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
    
    self.knobControl.lineWidth = 4.5;
    self.knobControl.pointerLength = 8.0;
    self.knobControl.tintColor = [UIColor colorWithRed:0.237 green:0.504 blue:1.000 alpha:1.000];
    [self.knobControl setValue:0.004 animated:NO];
    
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
    
    _freqencyDisplay = [[UILabel alloc] initWithFrame:CGRectMake(currentFrame.size.width/4, currentFrame.size.height/1.8, currentFrame.size.width/2, currentFrame.size.height/8)];
    _freqencyDisplay.text = @"0.0";
    [_freqencyDisplay setTextColor:[UIColor whiteColor]];
    [_freqencyDisplay setTextAlignment:NSTextAlignmentCenter];
    [_freqencyDisplay setFont:[UIFont boldSystemFontOfSize:35.0f]];
    [self.view addSubview:_freqencyDisplay];
    
    // Load data components
    _pitchDetector = [PitchDetector sharedDetector];
    [_pitchDetector TurnOnMicrophoneTuner:self];
    _noteData = [[GTNote alloc] init];
    
    _KVOController = [FBKVOController controllerWithObserver:self];
    [_KVOController observe:_noteData keyPath:@"currentNote" options:NSKeyValueObservingOptionNew block:^(MainViewController *observer, GTNote *object, NSDictionary *change) {
        NSLog(@"Changed: %@", change[NSKeyValueChangeNewKey]);
        [self performSelectorInBackground:@selector(updateNoteLabel) withObject:nil];
    }];

    [_KVOController observe:_noteData keyPath:@"currentFrequency" options:NSKeyValueObservingOptionNew block:^(MainViewController *observer, GTNote *object, NSDictionary *change) {
        //NSLog(@"FreqChange: %@", change[NSKeyValueChangeNewKey]);
        [self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
    }];
}

- (void)viewDidDisappear:(BOOL)animated
{
    _noteDisplay = nil;
    _freqencyDisplay = nil;
    [super viewDidDisappear:animated];
}

- (void)updateNoteLabel
{
    _noteDisplay.text = _noteData.currentNote;
}

- (void)updateFrequencyLabel
{
    _freqencyDisplay.text = [NSString stringWithFormat:@"%.2f", _noteData.currentFrequency];
    self.knobControl.minimumValue = _noteData.minFrequency;
    self.knobControl.maximumValue = _noteData.maxFreqency;
    
    count++;
    if (count >= 5 && _noteData.currentFrequency > _noteData.minFrequency && _noteData.currentFrequency < _noteData.maxFreqency) // Keeps tuner view from going crazy
    {
        [self.knobControl setValue:_noteData.currentFrequency animated:YES];
        count = 0;
    }
}

- (void)updateToFrequncy:(double)freqency
{
    NSString *huh = [NSString stringWithFormat:@"%.2f", freqency];

    if ([huh isEqualToString:lastFreq])
        [_noteData calculateCurrentNote:freqency];
    
    lastFreq = [NSString stringWithFormat:@"%.2f", freqency];
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
