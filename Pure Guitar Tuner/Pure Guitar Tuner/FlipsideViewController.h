//
//  FlipsideViewController.h
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
