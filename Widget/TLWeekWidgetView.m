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
#import "../Common/TLCalendarDisplayAttributeKeys.h"

#define CALENDAR_UNIT (NSYearForWeekOfYearCalendarUnit | NSWeekOfYearCalendarUnit | NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit)

#define WEEK_DAYS_MARGIN 2

#define WEEKDAY_RECT_WIDTH 36
#define WEEKDAY_RECT_HEIGHT 28

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
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
    
    // draw year/month
    CGContextSetFillColorWithColor(ctx, _captionTextColor.CGColor);
    NSString *text = [NSString stringWithFormat:@"%d年%d月 第%d周",
                      _dateComponents.year, _dateComponents.month, _dateComponents.weekOfYear];
    CGRect capRect = CGRectMake(0, 0, size.width, _captionFont.lineHeight);
    [text drawInRect:capRect
            withFont:_captionFont
       lineBreakMode:UILineBreakModeClip
           alignment:UITextAlignmentCenter];
    
    NSArray *weekdays = [_calendar chineseWeekdays];
    CGRect weekdayRect;
    weekdayRect.size = CGSizeMake(WEEKDAY_RECT_WIDTH, WEEKDAY_RECT_HEIGHT);
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    CGFloat y = CGRectGetMaxY(capRect) + _weekdayFont.lineHeight + WEEK_DAYS_MARGIN;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    for (int row = 0; row < 7; row++) {
        weekdayRect.origin = CGPointMake(x + row * weekdayRect.size.width, y);
        NSDictionary *attributes = [_dateAttributes objectAtIndex:row];
        NSDateComponents *comp = [attributes objectForKey:kTLDatesAttributeKeyDate];
        
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
        
        [self setFillColorWithAttributes:attributes componentOfToday:todayComps context:ctx];
        
        // draw day
        NSString *dayString = [NSString stringWithFormat:@"%d", comp.day];
        CGRect dayRect;
        dayRect.size = [dayString sizeWithFont:_dayFont forWidth:weekdayRect.size.width lineBreakMode:UILineBreakModeClip];
        dayRect.origin = CGPointMake(weekdayRect.origin.x + roundf((weekdayRect.size.width - dayRect.size.width) / 2),
                                     CGRectGetMidY(weekdayRect) - dayRect.size.height);
        [dayString drawInRect:dayRect
                     withFont:_dayFont
                lineBreakMode:UILineBreakModeClip
                    alignment:UITextAlignmentCenter];
        
        if ([todayComps isSameDayWithComponents:comp]) {
            // draw underline.
            CGContextSetLineWidth(ctx, 1.0f);
            CGPoint points[2] = {
                CGPointMake(dayRect.origin.x, CGRectGetMaxY(dayRect)),
                CGPointMake(CGRectGetMaxX(dayRect), CGRectGetMaxY(dayRect))
            };
            CGContextAddLines(ctx, points, 2);
            CGContextStrokePath(ctx);
        }
        
        // draw lunar day
        NSString *lunarDayString = [self detailForAttribute:attributes];
        CGRect lunarDayRect = CGRectMake(weekdayRect.origin.x,
                                         CGRectGetMidY(weekdayRect),
                                         weekdayRect.size.width,
                                         _lunarDayFont.lineHeight);
        [lunarDayString drawInRect:lunarDayRect
                          withFont:_lunarDayFont
                     lineBreakMode:UILineBreakModeClip
                         alignment:UITextAlignmentCenter];
        
        if ([_events objectForKey:comp]) {
            CGContextSetFillColorWithColor(ctx, self.eventHintColor.CGColor);
            CGContextAddEllipseInRect(ctx, CGRectMake(CGRectGetMaxX(dayRect) + 2, CGRectGetMinY(dayRect) + 2, 4, 4));
            CGContextFillPath(ctx);
        }
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
    NSDate *date = [_calendar dateByAddingComponents:diff toDate:current options:0];
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

- (NSDateComponents *)firstDay {
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
    if (c.day > 0) {
        c.day = c.day - 7;
    }
    NSDate *firstDayInView = [_calendar dateByAddingComponents:c toDate:firstDayOfWeek options:0];
    [c release];
    
    return [_calendar components:CALENDAR_UNIT fromDate:firstDayInView];
}

- (NSInteger)numberOfDays {
    return 7;
}

- (NSUInteger)dayIndexAtPoint:(CGPoint)point {
    CGFloat weekMinY = _captionFont.lineHeight + _weekdayFont.lineHeight + WEEK_DAYS_MARGIN;
    NSUInteger ret = NSNotFound;
    if (point.y > weekMinY) {
        int index = (int)floorf((point.x - (self.bounds.size.width - WEEKDAY_RECT_WIDTH * 7) / 2) / WEEKDAY_RECT_WIDTH);
        if (index >= 0 && index <= 6) {
            ret = index;
        }
    }
    return ret;
}

@end
