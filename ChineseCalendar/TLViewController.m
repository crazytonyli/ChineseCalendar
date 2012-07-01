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
#import "NSCalendarAdditons.h"
#include "solarterm.h"
#import <QuartzCore/QuartzCore.h>

#define WeePerfromSEL(sel) if ([_weeAppController respondsToSelector:sel]) [_weeAppController performSelector:sel];

@implementation TLViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 20, 320, 460)];
    view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"notificationcenter_bg"]];
    self.view = view;
    [view release];
    
    _weeAppController = [[NSClassFromString(@"LunarCalendarWidgetController") alloc] init];
    UIView *weeView = [_weeAppController view];
    weeView.frame = CGRectMake(0, 0, 320, [_weeAppController viewHeight]);
    [self.view addSubview:weeView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_weeAppController loadFullView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
    WeePerfromSEL(@selector(unloadView));
    [_weeAppController release];
    _weeAppController = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    WeePerfromSEL(@selector(viewWillAppear));
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    WeePerfromSEL(@selector(viewDidAppear));
    
    WeePerfromSEL(@selector(loadFullView));
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    WeePerfromSEL(@selector(viewWillDisappear));
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
    
    WeePerfromSEL(@selector(viewDidDisappear));
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

@end
