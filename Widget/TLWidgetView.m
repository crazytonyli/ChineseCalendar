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
#import "../Common/TLCalendarDisplayAttributeKeys.h"
#import "../Common/TLPreferences.h"
#include "../Common/lunardate.h"
#include "../Common/solarterm.h"

#define UIColorMakeWithRGBValue(value) \
[UIColor colorWithRed:((value >> 16) / 255.0) green:(((value & 0x00ff00) >> 8) / 255.0) blue:((value & 0x0000ff) / 255.0) alpha:1.0]

@implementation TLWidgetView

@synthesize dateComponents=_dateComponents;
@synthesize backgroundImage=_backgroundImage;
@synthesize captionFont=_captionFont;
@synthesize weekdayFont=_weekdayFont;
@synthesize dayFont=_dayFont;
@synthesize lunarDayFont=_lunarDayFont;
@synthesize captionTextColor=_captionTextColor;
@synthesize weekdayTextColor=_weekdayTextColor;
@synthesize weekendTextColor=_weekendTextColor;
@synthesize currentMonthDayColor=_currentMonthDayColor;
@synthesize notCurrentMonthDayColor=_notCurrentMonthDayColor;
@synthesize todayHighlightColor=_todayHighlightColor;
@synthesize festivalTextColor=_festivalTextColor;
@synthesize solarTermTextColor=_solarTermTextColor;
@synthesize eventHintColor=_eventHintColor;

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
        _captionTextColor = [[UIColor whiteColor] retain];
        _weekdayTextColor = [UIColorMakeWithRGBValue(0x8F9AD6) retain];
        _weekendTextColor = [UIColorMakeWithRGBValue(0xF9E794) retain];
        _currentMonthDayColor = [[UIColor whiteColor] retain];
        _notCurrentMonthDayColor = [UIColorMakeWithRGBValue(0xA8A8AD) retain];
        _todayHighlightColor = [UIColorMakeWithRGBValue(0x05C5FC) retain];
        _festivalTextColor = [UIColorMakeWithRGBValue(0xE4B262) retain];
        
        _calendar = [[NSCalendar sharedCalendar] retain];
    }
    return self;
}

- (void)dealloc {
    [_dateAttributes release];
    [_dateComponents release];
    [_calendar release];
    
    [_captionFont release];
    [_weekdayFont release];
    [_dayFont release];
    [_lunarDayFont release];
    
    [_captionTextColor release];
    [_weekdayTextColor release];
    [_weekendTextColor release];
    [_currentMonthDayColor release];
    [_notCurrentMonthDayColor release];
    [_todayHighlightColor release];
    [_festivalTextColor release];
    [_solarTermTextColor release];
    [_eventHintColor release];
    
    [_backgroundImage release];
    
    [super dealloc];
}

- (void)setDateAttributes:(NSArray *)attributes {
    [[attributes retain] autorelease];
    [_dateAttributes release];
    _dateAttributes = [attributes copy];
    
    [self setNeedsDisplay];
}

- (NSArray *)dateAttributes {
    return [[_dateAttributes retain] autorelease];
}

- (void)setEvents:(NSDictionary *)events {
    if (_events != events) {
        [_events release];
        _events = [events copy];
        
        [self setNeedsDisplay];
    }
}

- (NSDictionary *)events {
    return [[_events retain] autorelease];
}

- (BOOL)containsDateComponents:(NSDateComponents *)comp {
    return _dateComponents == comp;
}

- (BOOL)isValidDateComponents:(NSDateComponents *)comp {
    return YES;
}

- (void)setFillColorWithAttributes:(NSDictionary *)attributes
                  componentOfToday:(NSDateComponents *)todayComps
                           context:(CGContextRef)ctx {
    CGColorRef color = NULL;
    NSDateComponents *comp = [attributes objectForKey:kTLDatesAttributeKeyDate];
    BOOL festival = [attributes objectForKey:kTLDatesAttributeKeyFestivalSolar] 
    || [attributes objectForKey:kTLDatesAttributeKeyFestivalLunar]
    || [attributes objectForKey:kTLDatesAttributeKeySolarTerm];
    if (comp.month == _dateComponents.month) {
        if ([todayComps isSameDayWithComponents:comp]) {
            color = _todayHighlightColor.CGColor;
        } else {
            if (festival) {
                color = _festivalTextColor.CGColor;
            } else if ([attributes objectForKey:kTLDatesAttributeKeySolarTerm]) {
                color = _solarTermTextColor.CGColor;
            } else {
                if (comp.weekday == 7 || comp.weekday == 1) {
                    color = _weekendTextColor.CGColor;
                } else {
                    color = _currentMonthDayColor.CGColor;
                }
            }
        }
    } else {
        color = _notCurrentMonthDayColor.CGColor;
    }
    CGContextSetFillColorWithColor(ctx, color);
    CGContextSetStrokeColorWithColor(ctx, color);
}

- (NSString *)detailForAttribute:(NSDictionary *)attributes {
    NSString *detail = [attributes objectForKey:kTLDatesAttributeKeyFestivalLunar];
    if (detail == nil) {
        detail = [attributes objectForKey:kTLDatesAttributeKeyFestivalSolar];
    }
    if (detail == nil) {
        detail = [attributes objectForKey:kTLDatesAttributeKeySolarTerm];
    }
    if (detail == nil) {
        detail = [attributes objectForKey:kTLDatesAttributeKeyLunarDate];
    }
    return detail;
}

@end

