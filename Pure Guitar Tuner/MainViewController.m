//
//  MainViewController.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

@synthesize scrollView = m_scrollView;

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor whiteColor];
    
    m_scrollView = [[UIScrollView alloc] init];
    m_scrollView.frame = CGRectMake(0, 22, self.view.bounds.size.width, self.view.bounds.size.height/2);
    m_scrollView.contentSize = CGSizeMake(m_scrollView.frame.size.width * 4, m_scrollView.frame.size.height);

    m_scrollView.backgroundColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
    m_scrollView.showsVerticalScrollIndicator = NO;
    m_scrollView.showsHorizontalScrollIndicator = NO;
    m_scrollView.scrollEnabled = YES;
    
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"])
    {
        [[segue destinationViewController] setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController)
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
    else
    {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
