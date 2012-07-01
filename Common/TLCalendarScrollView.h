//
//  TLCalendarScrollView.h
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLCalendarDisplay.h"

@class TLCalendarScrollView;

@interface TLCalendarScrollView : UIScrollView<UIScrollViewDelegate> {
    NSArray *_views;
    NSCalendar *_calendar;
    BOOL _needLayoutWidgets;
}

@property (nonatomic, copy) NSArray *views;
@property (nonatomic, retain) NSDictionary *chineseFestivals;
@property (nonatomic, retain) NSDictionary *lunarFestivals;
@property (nonatomic, assign) BOOL showsSolarTerm;

- (id)initWithFrame:(CGRect)frame views:(NSArray *)views;

- (void)displayDate:(NSDate *)date;
- (void)displayDate:(NSDate *)date animated:(BOOL)animated;
- (BOOL)isDateShown:(NSDate *)date;

- (void)setNeedsLayoutWidgets;

- (NSDateComponents *)dateComponents;

- (NSString *)eventIdentifierForDayAtPoint:(CGPoint)point;
- (NSDateComponents *)dayAtPoint:(CGPoint)point;

@end
