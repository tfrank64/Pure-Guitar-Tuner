//
//  FlipsideViewController.m
//  Pure Guitar Tuner
//
//  Created by Taylor Franklin on 12/30/13.
//  Copyright (c) 2013 Taylor Franklin. All rights reserved.
//

#import "FlipsideViewController.h"

@interface FlipsideViewController ()

@end

@implementation FlipsideViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 22, self.view.bounds.size.width, 44)];
        [self.view addSubview:navBar];
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
        UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle:@"Options"];
        navBar.barTintColor = [UIColor colorWithRed:36.0/255.0 green:42.0/255.0 blue:50.0/255.0 alpha:1];
        navItem.leftBarButtonItem = doneButton;
        navBar.items = @[navItem];
        self.view.backgroundColor = [UIColor blackColor];
    }
}

#pragma mark - Actions

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
