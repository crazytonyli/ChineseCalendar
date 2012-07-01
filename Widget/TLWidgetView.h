//
//  TLWidgetView.h
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "../Common/lunardate.h"

@interface TLWidgetView : UIView {
    @package
    UIFont *_captionFont;
    UIFont *_weekdayFont;
    UIFont *_dayFont;
    UIFont *_lunarDayFont;
    
//    UIColor *_textColor;
    UIColor *_captionTextColor;
    UIColor *_weekdayTextColor;
    UIColor *_weekendTextColor;
    UIColor *_currentMonthDayColor;
    UIColor *_notCurrentMonthDayColor;
    UIColor *_todayHighlightColor;
    UIColor *_festivalTextColor;
    
    NSCalendar *_calendar;
    NSDateComponents *_dateComponents;
    NSDictionary *_events;
    
    NSArray *_dateAttributes;
    
    UIImage *_backgroundImage;
}

@property (nonatomic, copy) NSDateComponents *dateComponents;
@property (nonatomic, copy) NSArray *dateAttributes;
@property (nonatomic, copy) NSDictionary *events;

@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, retain) UIFont *captionFont;
@property (nonatomic, retain) UIFont *weekdayFont;
@property (nonatomic, retain) UIFont *dayFont;
@property (nonatomic, retain) UIFont *lunarDayFont;

@property (nonatomic, retain) UIColor *captionTextColor;
@property (nonatomic, retain) UIColor *weekdayTextColor;
@property (nonatomic, retain) UIColor *weekendTextColor;
@property (nonatomic, retain) UIColor *currentMonthDayColor;
@property (nonatomic, retain) UIColor *notCurrentMonthDayColor;
@property (nonatomic, retain) UIColor *todayHighlightColor;
@property (nonatomic, retain) UIColor *festivalTextColor;
@property (nonatomic, retain) UIColor *solarTermTextColor;
@property (nonatomic, retain) UIColor *eventHintColor;

- (BOOL)containsDateComponents:(NSDateComponents *)comp;

- (BOOL)isValidDateComponents:(NSDateComponents *)comp;

- (void)setFillColorWithAttributes:(NSDictionary *)attributes
                  componentOfToday:(NSDateComponents *)todayComps
                           context:(CGContextRef)ctx;

- (NSString *)detailForAttribute:(NSDictionary *)attributes;

- (void)setEvents:(NSDictionary *)events;

@end
