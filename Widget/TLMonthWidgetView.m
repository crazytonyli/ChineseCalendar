//
//  TLMonthWidgetView.m
//  Calendar
//
//  Created by Tony Li on 4/6/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLMonthWidgetView.h"
#import "../Common/TLLunarDate.h"
#import "../Common/NSDateComponentsAdditions.h"
#import "../Common/NSCalendarAdditons.h"

#define kColumnsCount 5

@implementation TLMonthWidgetView

@synthesize style=_style;

+ (CGFloat)minHeightForStyle:(TLMonthWidgetViewStyle)style {
    CGFloat height = 0;
    switch (style) {
        case TLMonthWidgetViewCompactStyle:
            height = 110.0f;
            break;
        case TLMonthWidgetViewLooseStyle:
            height = 176.0f;
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

- (void)layoutSubviews {
    // days of month
    NSRange range = [_calendar rangeOfUnit:NSDayCalendarUnit
                                    inUnit:NSMonthCalendarUnit
                                   forDate:[_calendar dateFromComponents:_dateComponents]];
    
    // info about first days of month
    NSDateComponents *comp = [_dateComponents copy];
    comp.day = range.location;
    NSDate *firstDayOfMonth = [_calendar dateFromComponents:comp];
    NSDateComponents *firstDayOfMonthComp = [_calendar components:NSWeekdayCalendarUnit fromDate:firstDayOfMonth];
    [comp release];
    
    // info about first cell in TLMonthView
    NSDateComponents *c = [[NSDateComponents alloc] init];
    c.day = [_calendar firstWeekday] - firstDayOfMonthComp.weekday;
    NSDate *firstDayInView = [_calendar dateByAddingComponents:c toDate:firstDayOfMonth options:0];
    [c release];
    
    // columns of TLMonthView
    if (_dates == nil) {
        _dates = [[NSMutableDictionary alloc] initWithCapacity:(7 * kColumnsCount)];
    } else {
        [_dates removeAllObjects];
    }
    
    NSDateComponents *offsetWithFirstDayInView = [[NSDateComponents alloc] init];
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < kColumnsCount; col++) {
            // calculate date of cell (row, col) by comparing to date of first cell
            offsetWithFirstDayInView.day = row + col * 7;
            NSDate *date = [_calendar dateByAddingComponents:offsetWithFirstDayInView toDate:firstDayInView options:0];
            NSUInteger indexes[2] = {row, col};
            [_dates setObject:[self datesAttributesForDate:date]
                       forKey:[NSIndexPath indexPathWithIndexes:indexes length:2]];
        }
    }
    [offsetWithFirstDayInView release];
    
    [self setNeedsDisplay];
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
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
            NSDateComponents *comp = [[_dates objectForKey:indexPath] objectForKey:kTLDatesAttributeKeyDate];
            
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
            
            CGColorRef color = NULL;
            if (comp.month == _dateComponents.month) {
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
                color = _notCurrentMonthDayColor.CGColor;
            }
            CGContextSetFillColorWithColor(ctx, color);
            
            NSString *dayStr = [NSString stringWithFormat:@"%d/", comp.day];
            CGSize daySize = [dayStr sizeWithFont:_dayFont];
            CGRect dayRect = CGRectMake(colX + _dayCellSize.width / 2 - daySize.width + 2, colY + (_dayCellSize.height - _dayFont.lineHeight) / 2, daySize.width, daySize.height);
            
            [dayStr drawInRect:dayRect withFont:_dayFont lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
            
            // draw lunar day
            TLLunarDate *lunarDate = [[_dates objectForKey:indexPath] objectForKey:kTLDatesAttributeKeyLunarDate];
            NSString *lunarDayString = lunarDate.lunarDay == 1 ? [lunarDate chineseMonth] : [lunarDate chineseDay];
            CGSize lunarDaySize = [lunarDayString sizeWithFont:_lunarDayFont];
            CGRect lunarDayRect = CGRectMake(CGRectGetMaxX(dayRect),
                                             colY + (_dayCellSize.height - _lunarDayFont.lineHeight) / 2,
                                             lunarDaySize.width,
                                             lunarDaySize.height);
            [lunarDayString drawInRect:lunarDayRect
                              withFont:_lunarDayFont
                         lineBreakMode:UILineBreakModeClip
                             alignment:UITextAlignmentCenter];
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
//            CGFloat colX = x + row * weekdayRect.size.width;
//            CGFloat colY = y + col * _dayCellSize.height;
            NSUInteger indexes[2] = { row, col };
            NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
            NSDateComponents *comp = [[_dates objectForKey:indexPath] objectForKey:kTLDatesAttributeKeyDate];
            
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
            
            CGColorRef color = NULL;
            if (comp.month == _dateComponents.month) {
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
                color = _notCurrentMonthDayColor.CGColor;
            }
            CGContextSetFillColorWithColor(ctx, color);
            
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
            
            // draw lunar day
            TLLunarDate *lunarDate = [[_dates objectForKey:indexPath] objectForKey:kTLDatesAttributeKeyLunarDate];
            NSString *lunarDayString = lunarDate.lunarDay == 1 ? [lunarDate chineseMonth] : [lunarDate chineseDay];
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
