//
//  TLWidgetView.h
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLWidgetView;
@class TLLunarDate;

@protocol TLWidgetViewDataSource <NSObject>

- (NSString *)widgetView:(TLWidgetView *)view lunarFestivalForDate:(TLLunarDate *)date;
- (NSString *)widgetView:(TLWidgetView *)view solarFestivalForDateComponents:(NSDateComponents *)comp;

@end

extern NSString * const kTLDatesAttributeKeyDate;
extern NSString * const kTLDatesAttributeKeyLunarDate;
extern NSString * const kTLDatesAttributeKeySolarTerm;
extern NSString * const kTLDatesAttributeKeyFestivalSolar;
extern NSString * const kTLDatesAttributeKeyFestivalLunar;

@interface TLWidgetView : UIView {
    @package
    UIFont *_captionFont;
    UIFont *_weekdayFont;
    UIFont *_dayFont;
    UIFont *_lunarDayFont;
    
    UIColor *_textColor;
    UIColor *_weekdayTextColor;
    UIColor *_weekendTextColor;
    UIColor *_currentMonthDayColor;
    UIColor *_notCurrentMonthDayColor;
    UIColor *_todayHighlightColor;
    UIColor *_festivalTextColor;
    
    NSCalendar *_calendar;
    NSDateComponents *_dateComponents;
    
    NSMutableDictionary *_dates;
    
    UIImage *_backgroundImage;
}

@property (assign) id<TLWidgetViewDataSource> dataSource;

@property (nonatomic, copy) NSDateComponents *dateComponents;

@property (nonatomic, retain) UIImage *backgroundImage;

@property (nonatomic, retain) UIFont *captionFont;
@property (nonatomic, retain) UIFont *weekdayFont;
@property (nonatomic, retain) UIFont *dayFont;
@property (nonatomic, retain) UIFont *lunarDayFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *weekdayTextColor;
@property (nonatomic, retain) UIColor *weekendTextColor;
@property (nonatomic, retain) UIColor *currentMonthDayColor;
@property (nonatomic, retain) UIColor *notCurrentMonthDayColor;
@property (nonatomic, retain) UIColor *todayHighlightColor;
@property (nonatomic, retain) UIColor *festivalTextColor;

- (NSDictionary *)datesAttributesForDate:(NSDate *)date;

- (void)setFillColorWithAttributes:(NSDictionary *)attributes
                  componentOfToday:(NSDateComponents *)todayComps
                           context:(CGContextRef)ctx;

- (NSString *)detailForAttribute:(NSDictionary *)attributes;

@end
