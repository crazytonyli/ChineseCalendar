//
//  TLViewController.m
//  CalendarWidget
//
//  Created by Tony Li on 4/12/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLViewController.h"
#import "TLCalendarScrollView.h"
#import "TLLunarCalendarWeeView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TLViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
        
    [view.calendarView displayCurrentDateWithAnimation:YES];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    view = [[TLLunarCalendarWeeView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    [view setViewType:TLLunarCalendarWeeViewDayType];
    [view setupCalendarView];
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2.0f;
    [self.view addSubview:view];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
