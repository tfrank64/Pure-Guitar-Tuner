//
//  MainViewController.h
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "FlipsideViewController.h"

@class RIOInterface;

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property(nonatomic, retain) UILabel *currentPitchLabel;
@property(nonatomic, retain) NSMutableString *key;
@property(nonatomic, retain) NSString *prevChar;
@property(nonatomic, assign) RIOInterface *rioRef;
@property(nonatomic, assign) float currentFrequency;
@property(assign) BOOL isListening;

- (void)frequencyChangedWithValue:(float)newFrequency;
- (void)updateFrequencyLabel;

@end
