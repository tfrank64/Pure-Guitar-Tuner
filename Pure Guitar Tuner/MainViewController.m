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

#define DSharp      330.5
#define D5          318.5
#define CSharp5     306.5
#define C5_y        294.5
#define B4_y        282.5
#define ASharp4_y   270.5
#define A4_y        258.5
#define GSharp4_y   246.5
#define G4_y        234.5
#define FSharp4_y   222.5
#define F4_y        210.5
#define E4_y        198.5
#define DSharp4_y   186.5
#define D4_y        174.5
#define CSharp4_y   162.5
#define C4_y        150.5
#define B3_y        138.5
#define ASharp3_y   126.5
#define A3_y        114.5
#define GSharp3_y   102.5
#define G3_y        90.5
#define FSharp3_y   78.5
#define F3_y        67.5
#define E3_y        54.5
#define DSharp3_y   42.5
#define D3_y        30.5
#define CSharp3_y   18.5
#define C3_y        6

@interface MainViewController ()
@end

@implementation MainViewController
{
    int count;
    UIButton *m_toggleButton;
}

@synthesize scrollView = m_scrollView;
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
    self.knobPlaceholder = [[UIView alloc] initWithFrame:CGRectMake(currentFrame.size.width/4, currentFrame.size.width/4, currentFrame.size.width/2, currentFrame.size.width/2)];
    //self.knobPlaceholder.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.knobPlaceholder];
    self.knobControl = [[RWKnobControl alloc] initWithFrame:self.knobPlaceholder.bounds];
    [self.knobPlaceholder addSubview:_knobControl];
    
    self.knobControl.lineWidth = 8.0;
    self.knobControl.pointerLength = 8.0;
    self.knobControl.tintColor = [UIColor colorWithRed:0.237 green:0.504 blue:1.000 alpha:1.000];
    
//    CGRect currentFrame = self.view.frame;
//    EFCircularSlider *circularSlider = [[EFCircularSlider alloc] initWithFrame:CGRectMake(currentFrame.size.width/4, currentFrame.size.width/4, currentFrame.size.width/2, currentFrame.size.width/2)];
//    circularSlider.unfilledColor = [UIColor colorWithRed:0.197 green:0.384 blue:1.000 alpha:1.000];
//    circularSlider.filledColor = [UIColor colorWithRed:0.306 green:0.138 blue:0.500 alpha:1.000];
//    circularSlider.lineWidth = 15;
//    circularSlider.handleType = EFSemiTransparentBlackCircle;
//    [self.view addSubview:circularSlider];
    
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
    
    m_currentPitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 400, 200, 44)];
    m_currentPitchLabel.text = @"0.0";
    m_currentPitchLabel.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:m_currentPitchLabel];
}

- (void)viewDidDisappear:(BOOL)animated
{
    m_currentPitchLabel = nil;
    [super viewDidDisappear:animated];
}

// This method gets called by the rendering function. Update the UI with
// the character type and store it in our string.

- (void)updateFrequencyLabel
{
    count++;
    if (count >= 20 && self.currentFrequency <= 500.0) // Keeps tuner view from going crazy
    {
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

- (int)midiToPosition:(int)midi
{
    switch (midi)
    {
        case 72:        return C5_y;
        case 71:        return B4_y;
        case 70:        return ASharp4_y;
        case 69:        return A4_y;
        case 68:        return GSharp4_y;
        case 67:        return G4_y;
        case 66:        return FSharp4_y;
        case 65:        return F4_y;
        case 64:        return E4_y;
        case 63:        return DSharp4_y;
        case 62:        return D4_y;
        case 61:        return CSharp4_y;
        case 60:        return C4_y;
        case 59:        return B3_y;
        case 58:        return ASharp3_y;
        case 57:        return A3_y;
        case 56:        return GSharp3_y;
        case 55:        return G3_y;
        case 54:        return FSharp3_y;
        case 53:        return F3_y;
        case 52:        return E3_y;
        case 51:        return DSharp3_y;
        case 50:        return D3_y;
        case 49:        return CSharp3_y;
        case 48:        return C3_y;
        default:
            if (midi<48)
                return -34;
            else
                return 330;
    }
}

- (void)moveIndicatorByMIDI:(int)midi
{
//    if (indicator.hidden)
//        return;
    int newFrequency = [self midiToPosition:midi];
    NSLog(@"midi: %d and frequency: %d", midi, newFrequency);
    //self.currentFrequency = newFrequency;
	[self performSelectorInBackground:@selector(updateFrequencyLabel) withObject:nil];
//    SKAction *easeMove = [SKAction moveToY:[self midiToPosition:midi] duration:0.2f];
//    easeMove.timingMode = SKActionTimingEaseInEaseOut;
//    [indicator runAction:easeMove];
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
