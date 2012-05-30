//
//  TLWidgetView.m
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLWidgetView.h"
#import "../Common/NSCalendarAdditons.h"
#import "../Common/NSDateComponentsAdditions.h"
#import "../Common/TLLunarDate.h"

UIColor *UIColorMakeWithRGBValue(int value);

NSString * const kTLDatesAttributeKeyDate = @"date";
NSString * const kTLDatesAttributeKeyLunarDate = @"date.lunar";
NSString * const kTLDatesAttributeKeyFestival = @"fest";
NSString * const kTLDatesAttributeKeyFestivalIsLunar = @"fest.lunar";

@implementation TLWidgetView

@synthesize dataSource=_dataSource;
@synthesize backgroundImage=_backgroundImage;
@synthesize captionFont=_captionFont;
@synthesize weekdayFont=_weekdayFont;
@synthesize dayFont=_dayFont;
@synthesize lunarDayFont=_lunarDayFont;
@synthesize textColor=_textColor;
@synthesize weekdayTextColor=_weekdayTextColor;
@synthesize weekendTextColor=_weekendTextColor;
@synthesize currentMonthDayColor=_currentMonthDayColor;
@synthesize notCurrentMonthDayColor=_notCurrentMonthDayColor;
@synthesize todayHighlightColor=_todayHighlightColor;
@synthesize holidayTextColor=_holidayTextColor;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor clearColor];
        
        _captionFont = [[UIFont boldSystemFontOfSize:14.0f] retain];
        _weekdayFont = [[UIFont boldSystemFontOfSize:12.0f] retain];
        _dayFont = [[UIFont boldSystemFontOfSize:12.0f] retain];
        _lunarDayFont = [[UIFont boldSystemFontOfSize:8.0f] retain];
        _textColor = [[UIColor whiteColor] retain];
        _weekdayTextColor = [UIColorMakeWithRGBValue(0x8F9AD6) retain];
        _weekendTextColor = [UIColorMakeWithRGBValue(0xd6be4c) retain];
        _currentMonthDayColor = [[UIColor whiteColor] retain];
        _notCurrentMonthDayColor = [UIColorMakeWithRGBValue(0xA8A8AD) retain];
        _todayHighlightColor = [UIColorMakeWithRGBValue(0x05C5FC) retain];
        _holidayTextColor = [UIColorMakeWithRGBValue(0xe8bc76) retain];
        
        _calendar = [[NSCalendar sharedCalendar] retain];
    }
    return self;
}

- (void)dealloc {
    [_dates release];
    [_dateComponents release];
    [_calendar release];
    
    [_captionFont release];
    [_weekdayFont release];
    [_dayFont release];
    [_lunarDayFont release];
    [_textColor release];
    [_weekdayTextColor release];
    [_weekendTextColor release];
    [_currentMonthDayColor release];
    [_notCurrentMonthDayColor release];
    [_todayHighlightColor release];
    [_holidayTextColor release];
    
    [_backgroundImage release];
    
    [super dealloc];
}

- (NSDateComponents *)dateComponents {
    return [[_dateComponents retain] autorelease];
}

- (void)setDateComponents:(NSDateComponents *)dateComponents {
    if (_dateComponents != dateComponents) {
        [_dateComponents release];
        _dateComponents = [dateComponents copy];
        
        [self setNeedsLayout];
        [self setNeedsDisplay];
    }
}

- (NSDictionary *)datesAttributesForDate:(NSDate *)date {
    const static NSCalendarUnit unit = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit);
    NSDateComponents *comp = [_calendar components:unit fromDate:date];
    TLLunarDate *lunarDate = [[TLLunarDate alloc] initWithSolarDateComponents:comp];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:4];
    [dict setObject:comp forKey:kTLDatesAttributeKeyDate];
    [dict setObject:lunarDate forKey:kTLDatesAttributeKeyLunarDate];
    
    BOOL isLunar = NO;
    NSString *fest = [_dataSource widgetView:self solarFestivalForDateComponents:comp];
    if (fest == nil) {
        fest = [_dataSource widgetView:self lunarFestivalForDate:lunarDate];
        isLunar = YES;
    }
    if (fest) {
        [dict setObject:fest forKey:kTLDatesAttributeKeyFestival];
        [dict setObject:[NSNumber numberWithBool:isLunar] forKey:kTLDatesAttributeKeyFestivalIsLunar];
    }
    
    return [dict autorelease];
}

- (void)setFillColorWithAttributes:(NSDictionary *)attributes
                  componentOfToday:(NSDateComponents *)todayComps
                           context:(CGContextRef)ctx {
    CGColorRef color = NULL;
    NSDateComponents *comp = [attributes objectForKey:kTLDatesAttributeKeyDate];
    if (comp.month == _dateComponents.month) {
        if ([attributes objectForKey:kTLDatesAttributeKeyFestival] == nil) {
            if ([todayComps isSameDayWithComponents:comp]) {
                color = _todayHighlightColor.CGColor;
            } else {
                if (comp.weekday == 7 || comp.weekday == 1) {
                    color = _weekendTextColor.CGColor;
                } else {
                    color = _currentMonthDayColor.CGColor;
                }
            }
        } else {
            color = _holidayTextColor.CGColor;
        }
    } else {
        if ([attributes objectForKey:kTLDatesAttributeKeyFestival]) {
            color = _holidayTextColor.CGColor;
        } else {
            color = _notCurrentMonthDayColor.CGColor;
        }
    }
    CGContextSetFillColorWithColor(ctx, color);
    CGContextSetStrokeColorWithColor(ctx, color);
}

- (NSString *)detailForAttribute:(NSDictionary *)attributes {
    NSString *detail = [attributes objectForKey:kTLDatesAttributeKeyFestival];
    if (detail == nil) {
        TLLunarDate *lunarDate = [attributes objectForKey:kTLDatesAttributeKeyLunarDate];
        detail = lunarDate.lunarDay == 1 ? [lunarDate chineseMonth] : [lunarDate chineseDay];
    }
    return detail;
}

@end

UIColor *UIColorMakeWithRGBValue(int value) {
    float red = (value >> 16) / 255.0;
    float green = ((value & 0x00ff00) >> 8) / 255.0;
    float blue = (value & 0x0000ff) / 255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}
