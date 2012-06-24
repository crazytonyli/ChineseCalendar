//
//  TLMonthWidgetView.m
//  Calendar
//
//  Created by Tony Li on 4/6/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLMonthWidgetView.h"
#import "../Common/lunardate.h"
#import "../Common/NSDateComponentsAdditions.h"
#import "../Common/NSCalendarAdditons.h"

#define kColumnsCount 6

int maxdaysofmonth(int year, int month);

@implementation TLMonthWidgetView

@synthesize style=_style;

+ (CGFloat)minHeightForStyle:(TLMonthWidgetViewStyle)style {
    CGFloat height = 0;
    switch (style) {
        case TLMonthWidgetViewCompactStyle:
            height = 126.0f;
            break;
        case TLMonthWidgetViewLooseStyle:
            height = 202.0f;
        default:
            break;
    }
    return height;
}

+ (CGSize)minSize {
    return CGSizeMake(316.0f, 110.0f);
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.style = TLMonthWidgetViewCompactStyle;
    }
    return self;
}

- (void)prepareDates {
    const static NSCalendarUnit unit = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit);
    
    // info about first days of month
    NSDateComponents *comp = [_dateComponents copy];
    comp.day = 1;
    NSDate *firstDayOfMonth = [_calendar dateFromComponents:comp];
    NSDateComponents *firstDayOfMonthComp = [_calendar components:unit fromDate:firstDayOfMonth];
    [comp release];
    
    // info about first cell in TLMonthView
    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.day = [_calendar firstWeekday] - firstDayOfMonthComp.weekday;
    if (c.day > 0) {
        c.day = c.day - 7;
    }
    NSDate *firstDayInView = [_calendar dateByAddingComponents:c toDate:firstDayOfMonth options:0];
    [c release];
    
    // columns of TLMonthView
    if (_dates == nil) {
        _dates = [[NSMutableDictionary alloc] initWithCapacity:(7 * kColumnsCount)];
    } else {
        [_dates removeAllObjects];
    }
    
    const static NSTimeInterval DAY_INTERVAL = 24 * 60 * 60;
    
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < kColumnsCount; col++) {
            NSDate *date = [NSDate dateWithTimeInterval:(DAY_INTERVAL * (row + col * 7)) sinceDate:firstDayInView];
            NSUInteger indexes[2] = {row, col};
            [_dates setObject:[self datesAttributesForDateComponents:[_calendar components:unit fromDate:date]]
                       forKey:[NSIndexPath indexPathWithIndexes:indexes length:2]];
        }
    }
}

- (BOOL)containsDateComponents:(NSDateComponents *)comp {
    return _dateComponents.year == comp.year && _dateComponents.month == comp.month;
}

- (BOOL)isValidDateComponents:(NSDateComponents *)comp {
    return comp.month <= 12 && comp.month > 0;
}

- (void)drawCompactStyle {
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
    weekdayRect.size = CGSizeMake(_dayCellSize.width, _weekdayFont.lineHeight);
    weekdayRect.origin.y = CGRectGetMaxY(capRect);
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    CGFloat y = CGRectGetMaxY(weekdayRect);
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < kColumnsCount; col++) {
            CGFloat colX = x + row * weekdayRect.size.width;
            CGFloat colY = y + col * _dayCellSize.height;
            NSUInteger indexes[2] = { row, col };
            NSDictionary *dict = [_dates objectForKey:[NSIndexPath indexPathWithIndexes:indexes length:2]];
            NSDateComponents *comp = [dict objectForKey:kTLDatesAttributeKeyDate];
            
            if (col == 0) {
                // draw weekday
                if (comp.weekday == 7 || comp.weekday == 1) {
                    CGContextSetFillColorWithColor(ctx, _weekendTextColor.CGColor);
                } else {
                    CGContextSetFillColorWithColor(ctx, _weekdayTextColor.CGColor);
                }
                
                weekdayRect.origin.x = x + row * weekdayRect.size.width;
                [[weekdays objectAtIndex:row] drawInRect:weekdayRect
                                                withFont:_weekdayFont
                                           lineBreakMode:UILineBreakModeTailTruncation
                                               alignment:UITextAlignmentCenter];
            }
            
            [self setFillColorWithAttributes:dict componentOfToday:todayComps context:ctx];
            
            NSString *dayStr = [NSString stringWithFormat:@"%d/", comp.day];
            CGSize daySize = [dayStr sizeWithFont:_dayFont];
            CGRect dayRect = CGRectMake(colX + _dayCellSize.width / 2 - daySize.width + 2, colY + (_dayCellSize.height - _dayFont.lineHeight) / 2, daySize.width, daySize.height);
            
            [dayStr drawInRect:dayRect withFont:_dayFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
            
            // draw lunar day
            NSString *lunarDayString = [self detailForAttribute:dict];
            CGSize lunarDaySize = [lunarDayString sizeWithFont:_lunarDayFont];
            CGRect lunarDayRect = CGRectMake(CGRectGetMaxX(dayRect),
                                             colY + (_dayCellSize.height - _lunarDayFont.lineHeight) / 2,
                                             lunarDaySize.width,
                                             lunarDaySize.height);
            [lunarDayString drawInRect:lunarDayRect
                              withFont:_lunarDayFont
                         lineBreakMode:UILineBreakModeClip
                             alignment:UITextAlignmentCenter];
            
            if ([todayComps isSameDayWithComponents:comp]) {
                // draw underline.
                CGContextSetLineWidth(ctx, 1.0f);
                CGPoint points[2] = {
                    CGPointMake(dayRect.origin.x, CGRectGetMaxY(dayRect)),
                    CGPointMake(CGRectGetMaxX(dayRect) + lunarDayRect.size.width, CGRectGetMaxY(dayRect))
                };
                CGContextAddLines(ctx, points, 2);
                CGContextStrokePath(ctx);
            }
        }
    }
}

- (void)drawLooseStyle {
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
    weekdayRect.size = _dayCellSize;
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    CGFloat y = CGRectGetMaxY(capRect) + _weekdayFont.lineHeight + 2;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < kColumnsCount; col++) {
            weekdayRect.origin = CGPointMake(x + row * weekdayRect.size.width, y + col * weekdayRect.size.height);
            NSUInteger indexes[2] = { row, col };
            NSDictionary *dict = [_dates objectForKey:[NSIndexPath indexPathWithIndexes:indexes length:2]];
            NSDateComponents *comp = [dict objectForKey:kTLDatesAttributeKeyDate];
            
            if (col == 0) {
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
            }
            
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
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [_backgroundImage drawInRect:CGRectInset(self.bounds, 2.0f, 0)];
    switch (_style) {
        case TLMonthWidgetViewCompactStyle:
            [self drawCompactStyle];
            break;
        case TLMonthWidgetViewLooseStyle:
            [self drawLooseStyle];
            break;
        default:
            break;
    }
}

#pragma mark - Accessors

- (void)setStyle:(TLMonthWidgetViewStyle)style {
    if (_style != style) {
        _style = style;
        
        [self setNeedsDisplay];
    }
    
    switch (style) {
        case TLMonthWidgetViewCompactStyle:
            _dayCellSize = CGSizeMake(44, 15);
            break;
        case TLMonthWidgetViewLooseStyle:
            _dayCellSize = CGSizeMake(36, 28);
            break;
        default:
            break;
    }
}

#pragma mark - TLCalendarDisplay protocol

- (NSDateComponents *)dateComponentsForCurrentDate {
    NSDateComponents *comp = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit) fromDate:[NSDate date]];
    comp.day = 1;
    return comp;
}

- (NSDateComponents *)previousDateComponents {
    NSDate *currentMonth = [_calendar dateFromComponents:[self dateComponents]];
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.month = -1;
    return [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit)
                        fromDate:[_calendar dateByAddingComponents:diff toDate:currentMonth options:0]];
}

- (NSDateComponents *)nextDateComponents {
    NSDate *currentMonth = [_calendar dateFromComponents:[self dateComponents]];
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.month = 1;
    return [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit)
                        fromDate:[_calendar dateByAddingComponents:diff toDate:currentMonth options:0]];
}

- (NSComparisonResult)compareWithDateComponents:(NSDateComponents *)target {
    NSComparisonResult result = NSOrderedSame;
    if (target.year > _dateComponents.year) {
        result = NSOrderedAscending;
    } else if (target.year == _dateComponents.year) {
        if (target.month > _dateComponents.month) {
            result = NSOrderedAscending;
        } else if (target.month == _dateComponents.month) {
            result = NSOrderedSame;
        } else {
            result = NSOrderedDescending;
        }
    } else {
        result = NSOrderedDescending;
    }
    return result;
}

- (NSCalendarUnit)calendarUnit {
    return (NSYearCalendarUnit | NSMonthCalendarUnit);
}

@end

int maxdaysofmonth(int year, int month) {
    const static BOOL LEAP_MONTH[12] = { 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1 };
    
    int maxDay;
    if (LEAP_MONTH[month - 1]) {
        maxDay = 31;
    } else {
        if (month == 2) {
            int year = year;
            if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
                maxDay = 29;
            } else {
                maxDay = 30;
            }
        } else {
            maxDay = 30;
        }
    }
    return maxDay;
}
