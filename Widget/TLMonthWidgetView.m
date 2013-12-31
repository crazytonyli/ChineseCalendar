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
#import "../Common/TLCalendarDisplayAttributeKeys.h"
#import "Common.h"

#define CALENDAR_UNIT (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit)

@implementation TLMonthWidgetView

@synthesize style=_style;
@synthesize rowCount=_rowCount;

+ (CGFloat)minHeightForStyle:(TLMonthWidgetViewStyle)style fullColumns:(BOOL)full {
    CGFloat height = 0;
    switch (style) {
        case TLMonthWidgetViewCompactStyle:
            height = full ? 130.f : 116.f;
            break;
        case TLMonthWidgetViewLooseStyle:
            height = full ? 197.f : 170.f;
            break;
        default:
            break;
    }
    return height;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.style = TLMonthWidgetViewCompactStyle;
        _rowCount = 6;
    }
    return self;
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
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
    }
    
    // draw year/month
    CGContextSetFillColorWithColor(ctx, _captionTextColor.CGColor);
    NSString *text = [NSString stringWithFormat:@"%d年%d月", _dateComponents.year, _dateComponents.month];
    CGRect capRect = CGRectMake(0, 0, size.width, _captionFont.lineHeight);
    [text drawInRect:capRect
            withFont:_captionFont
       lineBreakMode:UILineBreakModeClip
           alignment:UITextAlignmentCenter];
    
    NSArray *weekdays = [_calendar chineseWeekdays];
    CGRect weekdayRect;
    weekdayRect.size = CGSizeMake(_dayCellSize.width, _weekdayFont.lineHeight);
    weekdayRect.origin = CGPointMake(0, CGRectGetMaxY(capRect));
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    CGFloat y = CGRectGetMaxY(weekdayRect);
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < _rowCount; col++) {
            CGFloat colX = x + row * weekdayRect.size.width;
            CGFloat colY = y + col * _dayCellSize.height;
            NSDictionary *dict = [_dateAttributes objectAtIndex:(row + col * 7)];
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
            
            if ([_events objectForKey:comp]) {
                CGContextSetFillColorWithColor(ctx, self.eventHintColor.CGColor);
                CGContextAddEllipseInRect(ctx, CGRectMake(CGRectGetMaxX(dayRect) + lunarDayRect.size.width + 2, CGRectGetMinY(dayRect) + 2, 4, 4));
                CGContextFillPath(ctx);
            }
        }
    }
}

- (void)drawLooseStyle {
    CGSize size = self.bounds.size;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
    }
    
    // draw year/month
    CGContextSetFillColorWithColor(ctx, _captionTextColor.CGColor);
    NSString *text = [NSString stringWithFormat:@"%d年%d月", _dateComponents.year, _dateComponents.month];
    CGRect capRect = CGRectMake(0, 0, size.width, _captionFont.lineHeight);
    [text drawInRect:capRect
            withFont:_captionFont
       lineBreakMode:UILineBreakModeClip
           alignment:UITextAlignmentCenter];
    
    NSArray *weekdays = [_calendar chineseWeekdays];
    CGRect weekdayRect;
    weekdayRect.size = _dayCellSize;
    CGFloat x = (size.width - weekdayRect.size.width * 7) / 2;
    CGFloat y = CGRectGetMaxY(capRect) + _weekdayFont.lineHeight + 2;
    
    // draw day cells
    NSDateComponents *todayComps = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                                                fromDate:[NSDate date]];
    for (int row = 0; row < 7; row++) {
        for (int col = 0; col < _rowCount; col++) {
            weekdayRect.origin = CGPointMake(x + row * weekdayRect.size.width, y + col * weekdayRect.size.height);
            NSDictionary *dict = [_dateAttributes objectAtIndex:(row + col * 7)];
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
            NSString *lunarDayString = [self detailForAttribute:dict];
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
            _dayCellSize = CGSizeMake(44, 16);
            break;
        case TLMonthWidgetViewLooseStyle:
            _dayCellSize = CGSizeMake(36, 27);
            break;
        default:
            break;
    }
}

#pragma mark - TLCalendarDisplay protocol

- (NSDateComponents *)dateComponentsForCurrentDate {
    NSDateComponents *comp = [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit) fromDate:[NSDate date]];
    comp.day = 1;
    return comp;
}

- (NSDateComponents *)previousDateComponents {
    NSDate *currentMonth = [_calendar dateFromComponents:[self dateComponents]];
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.month = -1;
    return [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
                        fromDate:[_calendar dateByAddingComponents:diff toDate:currentMonth options:0]];
}

- (NSDateComponents *)nextDateComponents {
    NSDate *currentMonth = [_calendar dateFromComponents:[self dateComponents]];
    NSDateComponents *diff = [[[NSDateComponents alloc] init] autorelease];
    diff.month = 1;
    return [_calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit)
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
    return CALENDAR_UNIT;
}

- (NSDateComponents *)firstDay {
    NSDateComponents *comp = [_dateComponents copy];
    comp.day = 1;
    NSDate *firstDayOfMonth = [_calendar dateFromComponents:comp];
    NSDateComponents *firstDayOfMonthComp = [_calendar components:CALENDAR_UNIT fromDate:firstDayOfMonth];
    [comp release];
    
    // info about first cell in TLMonthView
    NSDateComponents *diff = [[NSDateComponents alloc] init];
    diff.day = [_calendar firstWeekday] - firstDayOfMonthComp.weekday;
    if (diff.day > 0) {
        diff.day = diff.day - 7;
    }
    NSDate *firstDayInView = [_calendar dateByAddingComponents:diff toDate:firstDayOfMonth options:0];
    [diff release];
    
    return [_calendar components:CALENDAR_UNIT fromDate:firstDayInView];;
}

- (NSInteger)numberOfDays {
    return _rowCount * 7;
}

- (NSUInteger)dayIndexAtPoint:(CGPoint)point {
    CGFloat minY = _captionFont.lineHeight + _weekdayFont.lineHeight;
    CGFloat weekWidth = _dayCellSize.width * 7;
    if (point.x < (self.bounds.size.width - weekWidth) / 2
        || point.x > (self.bounds.size.width + weekWidth) / 2
        || point.y < minY
        ) {
        return NSNotFound;
    }
    
    int row = (int)floorf((point.y - minY) / _dayCellSize.height);
    int col = (int)floorf((point.x - ((self.bounds.size.width - weekWidth) / 2)) / _dayCellSize.width);
    if (row >= 0 && row < _rowCount && col >= 0 && col < 7) {
        return col + row * 7;
    } else {
        return NSNotFound;
    }
}

@end
