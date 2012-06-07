//
//  TLWeekWidgetView.m
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLWeekWidgetView.h"
#import "../Common/NSCalendarAdditons.h"
#import "../Common/NSDateComponentsAdditions.h"
#include "../Common/lunardate.h"

#define CALENDAR_UNIT (NSYearForWeekOfYearCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit)

@implementation TLWeekWidgetView

+ (CGFloat)minHeight {
    return 64.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareDates {
    // days of week
    NSRange range = [_calendar rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSWeekCalendarUnit
                                   forDate:[_calendar dateFromComponents:_dateComponents]];
    // info about first days of week
    NSDateComponents *comp = [_dateComponents copy];
    comp.day = range.location;
    NSDate *firstDayOfWeek = [_calendar dateFromComponents:comp];
    NSDateComponents *firstDayOfWeekComp = [_calendar components:NSWeekdayCalendarUnit fromDate:firstDayOfWeek];
    [comp release];
    
    // info about first cell in TLMonthView
    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.day = [_calendar firstWeekday] - firstDayOfWeekComp.weekday;
    NSDate *firstDayInView = [_calendar dateByAddingComponents:c toDate:firstDayOfWeek options:0];
    [c release];
    
    // columns of TLMonthView
    if (_dates == nil) {
        _dates = [[NSMutableDictionary alloc] initWithCapacity:7];
    } else {
        [_dates removeAllObjects];
    }
    
    const NSCalendarUnit unit = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit);
    const static NSTimeInterval DAY_INTERVAL = 24 * 60 * 60;
    for (int row = 0; row < 7; row++) {
        // calculate date of cell (row, col) by comparing to date of first cell
        NSDate *date = [NSDate dateWithTimeInterval:(DAY_INTERVAL * row) sinceDate:firstDayInView];
        [_dates setObject:[self datesAttributesForDateComponents:[_calendar components:unit fromDate:date]]
                   forKey:[NSNumber numberWithInt:row]];
    }
}

- (BOOL)containsDateComponents:(NSDateComponents *)comp {
    return _dateComponents.year == comp.year && _dateComponents.weekOfYear == comp.weekOfYear;
}

- (BOOL)isValidDateComponents:(NSDateComponents *)comp {
    return comp.weekOfYear > 0 && comp.weekOfYear < 55;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [_backgroundImage drawInRect:CGRectInset(self.bounds, 2.0f, 0)];
    
    CGSize size = self.bounds.size;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, _textColor.CGColor);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
    
    // draw year/month
    NSString *text = [NSString stringWithFormat:@"%d年%d月", _dateComponents.year, _dateComponents.month];
    CGRect capRect = CGRectMake(0, 0, size.width, _captionFont.lineHeight);
    [text drawInRect:capRect
            withFont:_captionFont
       lineBreakMode:UILineBreakModeClip
           alignment:UITextAlignmentCenter];
    
    NSArray *weekdays = [_calendar chineseWeekdaysWithPrefix:@"周"];
    CGRect weekdayRect;
    weekdayRect.size = CGSizeMake(36, 28);
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    CGFloat y = CGRectGetMaxY(capRect) + _weekdayFont.lineHeight + 2;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    for (int row = 0; row < 7; row++) {
        weekdayRect.origin = CGPointMake(x + row * weekdayRect.size.width, y);
        NSDictionary *dict = [_dates objectForKey:[NSNumber numberWithInt:row]];
        NSDateComponents *comp = [dict objectForKey:kTLDatesAttributeKeyDate];
        
        // draw weekday
        if (comp.weekday == 7 || comp.weekday == 1) {
            CGContextSetFillColorWithColor(ctx, _weekendTextColor.CGColor);
        } else {
            CGContextSetFillColorWithColor(ctx, _weekdayTextColor.CGColor);
        }
        
        CGRect r = weekdayRect;
        r.origin.y -= (_weekdayFont.lineHeight + 2);
        [[weekdays objectAtIndex:row] drawInRect:r
                                        withFont:_weekdayFont
                                   lineBreakMode:UILineBreakModeTailTruncation
                                       alignment:UITextAlignmentCenter];
        
        [self setFillColorWithAttributes:dict componentOfToday:todayComps context:ctx];
        
        // draw day
        NSString *dayString = [NSString stringWithFormat:@"%d", comp.day];
        CGRect dayRect = CGRectMake(weekdayRect.origin.x,
                                    CGRectGetMidY(weekdayRect) - _dayFont.lineHeight,
                                    weekdayRect.size.width,
                                    _dayFont.lineHeight);
        [dayString drawInRect:dayRect
                     withFont:_dayFont
                lineBreakMode:UILineBreakModeClip
                    alignment:UITextAlignmentCenter];
        
        if ([todayComps isSameDayWithComponents:comp]) {
            // draw underline.
            CGContextSetLineWidth(ctx, 1.0f);
            CGSize size = [dayString sizeWithFont:_dayFont forWidth:dayRect.size.width lineBreakMode:UILineBreakModeClip];
            CGFloat y = CGRectGetMaxY(dayRect);
            CGPoint points[2] = {
                CGPointMake(dayRect.origin.x + roundf((dayRect.size.width - size.width) / 2), y),
                CGPointMake(CGRectGetMaxX(dayRect) - roundf((dayRect.size.width - size.width) / 2), y)
            };
            CGContextAddLines(ctx, points, 2);
            CGContextStrokePath(ctx);
        }
        
        // draw lunar day
        NSString *lunarDayString = [self detailForAttribute:dict];
        CGRect lunarDayRect = CGRectMake(weekdayRect.origin.x,
                                         CGRectGetMidY(weekdayRect),
                                         weekdayRect.size.width,
                                         _lunarDayFont.lineHeight);
        [lunarDayString drawInRect:lunarDayRect
                          withFont:_lunarDayFont
                     lineBreakMode:UILineBreakModeClip
                         alignment:UITextAlignmentCenter];
    }
}

#pragma mark - TLCalendarDisplay protocol

- (NSDateComponents *)dateComponentsForCurrentDate {
    return [_calendar components:CALENDAR_UNIT fromDate:[NSDate date]];
}

- (NSDateComponents *)previousDateComponents {
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.weekOfYear = -1;
    NSDate *date = [_calendar dateByAddingComponents:diff
                                              toDate:[_calendar dateFromComponents:[self dateComponents]]
                                             options:0];
    return [_calendar components:CALENDAR_UNIT fromDate:date];
}

- (NSDateComponents *)nextDateComponents {
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.weekOfYear = 1;
    NSDate *current = [_calendar dateFromComponents:[self dateComponents]];
    NSDate *date = [_calendar dateByAddingComponents:diff
                                              toDate:current
                                             options:0];
    NSLog(@"Current: %@, Next: %@", current, date);
    return [_calendar components:CALENDAR_UNIT fromDate:date];
}

- (NSComparisonResult)compareWithDateComponents:(NSDateComponents *)target {
    NSComparisonResult result = NSOrderedSame;
    if (target.year > _dateComponents.year) {
        result = NSOrderedAscending;
    } else if (target.year == _dateComponents.year) {
        if (target.month > _dateComponents.month) {
            result = NSOrderedAscending;
        } else if (target.month == _dateComponents.month) {
            if (target.weekOfYear > _dateComponents.weekOfYear) {
                result = NSOrderedAscending;
            } else if (target.weekOfYear == _dateComponents.weekOfYear) {
                result = NSOrderedSame;
            } else {
                result = NSOrderedDescending;
            }
        } else {
            result = NSOrderedDescending;
        }
    } else {
        result = NSOrderedDescending;
    }
    return result;
}

- (NSCalendarUnit)calendarUnit {
    return CALENDAR_UNIT;
}

@end
