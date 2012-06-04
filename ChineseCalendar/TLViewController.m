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
#import "TLLunarDate.h"
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
    [view setViewType:TLLunarCalendarWeeViewMonthType];
    [view setupCalendarView];
    view.layer.borderColor = [UIColor whiteColor].CGColor;
    view.layer.borderWidth = 2.0f;
    [self.view addSubview:view];
	// Do any additional setup after loading the view, typically from a nib.
    
    /*
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    TLLunarDate *lastTerm = nil;
    NSDateComponents *comp = [[[NSDateComponents alloc] init] autorelease];
    comp.year = 1901;
    comp.month = 1;
    comp.day = 1;
    const NSTimeInterval dayInterval = 24 * 60 * 60;
    NSDateComponents *diff = [[NSDateComponents alloc] init];
    diff.day = 1;
    NSMutableSet *set = [NSMutableSet setWithCapacity:4];
    while (!(comp.year == 2099 && comp.month == 12 && comp.day == 31)) {
        NSDate *current = [calendar dateFromComponents:comp];
        TLLunarDate *lunar = [[TLLunarDate alloc] initWithSolarDateComponents:comp];
        if ([lunar solarTerm]) {
            if (lastTerm) {
                NSDate *last = [calendar dateFromComponents:lastTerm.solarDateComponent];
                int days = (int)floor([current timeIntervalSinceDate:last] / dayInterval);
                [set addObject:[NSNumber numberWithInt:days]];
            }
            
            [lastTerm release];
            lastTerm = [lunar retain];
        }
        [lunar release];
        
        comp = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                           fromDate:[calendar dateByAddingComponents:diff toDate:current options:0]];
    }
    for (NSNumber *num in set) {
        NSLog(@"%d", [num intValue]);
    }
     */
}

/*
 0-4 春分日期
 5-6 春分月份
 0-13
 */

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
