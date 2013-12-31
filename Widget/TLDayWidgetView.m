//
//  TLDayWidgetView.m
//  Calendar
//
//  Created by Tony Li on 4/29/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLDayWidgetView.h"
#import "../Common/NSCalendarAdditons.h"
#import "../Common/NSDateComponentsAdditions.h"
#import "../Common/lunardate.h"
#import "Common.h"

@implementation TLDayWidgetView

+ (CGFloat)minHeight {
    return 58.0f;
}

- (id)initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
        self.captionFont = [UIFont boldSystemFontOfSize:14];
        self.lunarDayFont = [UIFont boldSystemFontOfSize:16];
    }
    return self;
}

- (BOOL)containsDateComponents:(NSDateComponents *)comp {
    return _dateComponents.year == comp.year && _dateComponents.month == comp.month && _dateComponents.day == comp.day;
}

- (void)drawRect:(CGRect)rect {
    [_backgroundImage drawInRect:CGRectInset(self.bounds, 2.0f, 0)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0, [UIColor blackColor].CGColor);
    }
    
    if ([_dateComponents isSameDayWithComponents:[self dateComponentsForCurrentDate]]) {
        CGContextSetFillColorWithColor(ctx, _todayHighlightColor.CGColor);
    } else {
        CGContextSetFillColorWithColor(ctx, _currentMonthDayColor.CGColor);
    }
    
    const NSString *weekdays[7] = { @"星期日", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六" };
    NSString *text = [NSString stringWithFormat:@"%d年%d月%d日 %@",
                      _dateComponents.year, _dateComponents.month,
                      _dateComponents.day, weekdays[_dateComponents.weekday - 1]];
    CGSize size = [text sizeWithFont:_captionFont constrainedToSize:rect.size];
    CGRect drawRect = CGRectMake(roundf((rect.size.width - size.width) / 2),
                                 roundf((rect.size.height - _captionFont.lineHeight - _lunarDayFont.lineHeight) / 2),
                                 size.width, _captionFont.lineHeight);
    [text drawInRect:drawRect
            withFont:_captionFont
       lineBreakMode:UILineBreakModeTailTruncation
           alignment:UITextAlignmentCenter];
    
    LunarDate lunar = lunardate_from_solar(_dateComponents.year, _dateComponents.month, _dateComponents.day);
    NSString *lunarText = [NSString stringWithFormat:@"农历%@%@%@年%@%@",
                           [NSString stringWithUTF8String:lunardate_tiangan(lunar.year)],
                           [NSString stringWithUTF8String:lunardate_dizhi(lunar.year)],
                           [NSString stringWithUTF8String:lunardate_zodiac(lunar.year)],
                           [NSString stringWithUTF8String:lunardate_month(lunar.month)],
                           [NSString stringWithUTF8String:lunardate_day(lunar.day)]];
    drawRect.size = [lunarText sizeWithFont:_lunarDayFont constrainedToSize:rect.size];
    drawRect.origin.x = roundf((rect.size.width - drawRect.size.width) / 2);
    drawRect.origin.y += _captionFont.lineHeight;
    [lunarText drawInRect:drawRect withFont:_lunarDayFont
            lineBreakMode:UILineBreakModeTailTruncation alignment:UITextAlignmentCenter];
}

#pragma mark - TLCalendarDisplay protocol

- (NSDateComponents *)previousDateComponents {
    NSDateComponents *diff = [[NSDateComponents alloc] init];
    diff.day = -1;
    NSDate *date = [_calendar dateByAddingComponents:diff toDate:[_calendar dateFromComponents:_dateComponents] options:0];
    [diff release];
    return [_calendar components:[self calendarUnit] fromDate:date];
}

- (NSDateComponents *)nextDateComponents {
    NSDateComponents *diff = [[NSDateComponents alloc] init];
    diff.day = 1;
    NSDate *date = [_calendar dateByAddingComponents:diff toDate:[_calendar dateFromComponents:_dateComponents] options:0];
    [diff release];
    return [_calendar components:[self calendarUnit] fromDate:date];
}

- (NSDateComponents *)dateComponentsForCurrentDate {
    return [_calendar components:[self calendarUnit] fromDate:[NSDate date]];
}

- (NSComparisonResult)compareWithDateComponents:(NSDateComponents *)target {
    NSComparisonResult result = NSOrderedSame;
    if (target.year > _dateComponents.year) {
        result = NSOrderedAscending;
    } else if (target.year == _dateComponents.year) {
        if (target.month > _dateComponents.month) {
            result = NSOrderedAscending;
        } else if (target.month == _dateComponents.month) {
            if (target.day > _dateComponents.day) {
                result = NSOrderedAscending;
            } else if (target.day == _dateComponents.day) {
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
    return NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit;
}

- (NSDateComponents *)firstDay {
    return [[_dateComponents copy] autorelease];
}

- (NSInteger)numberOfDays {
    return 1;
}

- (NSUInteger)dayIndexAtPoint:(CGPoint)point {
    return 0;
}

@end
