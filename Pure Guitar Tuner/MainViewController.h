//
//  MainViewController.h
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "FlipsideViewController.h"
#import "PitchDetector.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (nonatomic, retain) UILabel *currentPitchLabel;
@property( nonatomic, retain) NSMutableString *key;
@property (nonatomic, retain) NSString *prevChar;
@property (nonatomic, assign) int currentFrequency;
@property (nonatomic, strong) NSString *currentNote;
@property(assign) BOOL isListening;

@property (nonatomic, strong) PitchDetector *pitchDetector;

- (void)updateFrequencyLabel;

-(int)midiToPosition:(int)midi;
-(void)moveIndicatorByMIDI:(int)midi;

@end
