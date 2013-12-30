//
//  MainViewController.h
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@end
