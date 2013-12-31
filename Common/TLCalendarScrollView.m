//
//  TLCalendarScrollView.m
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLCalendarScrollView.h"
#import "NSCalendarAdditons.h"
#import "TLCalendarDisplayAttributeKeys.h"
#include "lunardate.h"
#include "solarterm.h"

@interface TLCalendarScrollView(/*PrivateMethods*/)

- (void)layoutWidgets;
- (void)setupDsiplay:(id<TLCalendarDisplay>)display withDateComponent:(NSDateComponents *)comp;
- (NSMutableArray *)attributesForDisplay:(id<TLCalendarDisplay>)display;

@end

@implementation TLCalendarScrollView

@synthesize chineseFestivals=_chineseFestivals;
@synthesize lunarFestivals=_lunarFestivals;
@synthesize showsSolarTerm=_showsSolarTerm;

- (id)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame views:nil];
}

- (id)initWithFrame:(CGRect)frame views:(NSArray *)views {
    if ( (self = [super initWithFrame:frame]) ) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.bounces = NO;
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        
        self.views = views;
        
        _calendar = [[NSCalendar sharedCalendar] retain];
    }
    return self;
}

- (void)dealloc {
    [_views release];
    [_calendar release];
    [_chineseFestivals release];
    [_lunarFestivals release];

    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(self.frame, frame)) {
        [super setFrame:frame];
        
        self.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
        self.contentOffset = CGPointMake(frame.size.width, 0);
        [[_views objectAtIndex:0] setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [[_views objectAtIndex:1] setFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
        [[_views objectAtIndex:2] setFrame:CGRectMake(frame.size.width * 2, 0, frame.size.width, frame.size.height)];
        [[_views objectAtIndex:1] setNeedsDisplay];
    }
}

- (void)layoutSubviews {
    if (_needLayoutWidgets) {
        [self layoutWidgets];
        
        _needLayoutWidgets = NO;
    }
}

#pragma mark - Public method

- (NSArray *)views {
    return _views;
}

- (void)setViews:(NSArray *)views {
    if (_views != views) {
        if (_views) {
            for (int i = 0; i < [_views count]; i++) {
                [[_views objectAtIndex:i] removeFromSuperview];
            }
            
            [_views release];
            _views = nil;
        }
        
        if (views) {
            _views = [views copy];
            
            CGRect frame;
            frame.size = self.bounds.size;
            frame.origin.y = 0;
            for (int i = 0; i < [views count]; i++) {
                UIView *view = [views objectAtIndex:i];
                frame.origin.x = i * frame.size.width;
                view.userInteractionEnabled = NO;
                [self addSubview:view];
            }
            
            _needLayoutWidgets = YES;
        }
    }
}

- (void)setChineseFestivals:(NSDictionary *)chineseFestivals {
    if (_chineseFestivals != chineseFestivals) {
        [_chineseFestivals release];
        _chineseFestivals = [chineseFestivals retain];
        
        [self setNeedsLayoutWidgets];
    }
}

- (void)setLunarFestivals:(NSDictionary *)lunarFestivals {
    if (_lunarFestivals != lunarFestivals) {
        [_lunarFestivals release];
        _lunarFestivals = [lunarFestivals retain];
        
        [self setNeedsLayoutWidgets];
    }
}

- (void)setShowsSolarTerm:(BOOL)showsSolarTerm {
    if (_showsSolarTerm != showsSolarTerm) {
        _showsSolarTerm = showsSolarTerm;
        [self setNeedsLayoutWidgets];
    }
}

- (void)displayDate:(NSDate *)date {
    [self displayDate:date animated:YES];
}

- (void)displayDate:(NSDate *)date animated:(BOOL)animated {
    if (_views) {
        id<TLCalendarDisplay> current = [_views objectAtIndex:1];
        NSDateComponents *comp = [_calendar components:[current calendarUnit] fromDate:date];
        UIView<TLCalendarDisplay> *targetView = nil;
        switch ([current compareWithDateComponents:comp]) {
            case NSOrderedAscending: // 今天(comp)在当前显示月之后
                targetView = [_views objectAtIndex:2];
                break;
            case NSOrderedDescending: // 今天(comp)在当前显示月之前
                targetView = [_views objectAtIndex:0];
                break;
            default:
                break;
        }
        
        if (targetView) {
            [self setupDsiplay:targetView withDateComponent:comp];
            [self scrollRectToVisible:targetView.frame animated:animated];
            
            if (!animated) {
                [self layoutWidgets];
            }
        } else {
            [[_views objectAtIndex:1] setNeedsDisplay];
        }
    }
}

- (BOOL)isDateShown:(NSDate *)date {
    id<TLCalendarDisplay> current = [_views objectAtIndex:1];
    NSDateComponents *comp = [_calendar components:[current calendarUnit] fromDate:date];
    return [current compareWithDateComponents:comp] == NSOrderedSame;
}

- (void)setNeedsLayoutWidgets {
    _needLayoutWidgets = YES;
    [self setNeedsLayout];
}

- (NSDateComponents *)dateComponents {
    return [[_views objectAtIndex:1] dateComponents];
}

- (NSString *)eventIdentifierForDayAtPoint:(CGPoint)point {
    UIView<TLCalendarDisplay> *display = [_views objectAtIndex:1];
    NSUInteger index = [display dayIndexAtPoint:[self convertPoint:point toView:display]];
    NSString *eid = nil;
    if (index != NSNotFound) {
        NSDateComponents *dayComp = [[[display dateAttributes] objectAtIndex:index] objectForKey:kTLDatesAttributeKeyDate];
        eid = [[display events] objectForKey:dayComp];
    }
    return eid;
}

- (NSDateComponents *)dayAtPoint:(CGPoint)point {
    UIView<TLCalendarDisplay> *display = [_views objectAtIndex:1];
    NSUInteger index = [display dayIndexAtPoint:[self convertPoint:point toView:display]];
    return index != NSNotFound ? [[[display dateAttributes] objectAtIndex:index] objectForKey:kTLDatesAttributeKeyDate] : nil;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self setNeedsLayoutWidgets];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self setNeedsLayoutWidgets];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self setNeedsLayoutWidgets];
}

#pragma mark - Private methods

- (void)layoutWidgets {
    CGSize size = self.bounds.size;
    CGPoint contentOffset = self.contentOffset;
    UIView<TLCalendarDisplay> *prev = nil, *current = nil, *next = nil;
    if (contentOffset.x == 0) {
        prev = [_views objectAtIndex:2];
        current = [_views objectAtIndex:0];
        next = [_views objectAtIndex:1];
    } else if (contentOffset.x == size.width) {
        prev = [_views objectAtIndex:0];
        current = [_views objectAtIndex:1];
        next = [_views objectAtIndex:2];
    } else if (contentOffset.x == size.width * 2) {
        prev = [_views objectAtIndex:1];
        current = [_views objectAtIndex:2];
        next = [_views objectAtIndex:0];
    }
    
    if (prev && current && next) {
        
        NSDateComponents *currentComponents = [current dateComponents];
        
        if (currentComponents == nil) {
            currentComponents = [current dateComponentsForCurrentDate];
        }
        
        prev.frame = CGRectMake(0, 0, size.width, size.height);
        current.frame = CGRectMake(size.width, 0, size.width, size.height);
        next.frame = CGRectMake(size.width * 2, 0, size.width, size.height);
        
        NSArray *views = [NSArray arrayWithObjects:prev, current, next, nil];
        [_views release];
        _views = [views retain];
        
        self.contentOffset = CGPointMake(size.width, 0);
        
        [self setupDsiplay:current withDateComponent:currentComponents];
        [self setupDsiplay:prev withDateComponent:[current previousDateComponents]];
        [self setupDsiplay:next withDateComponent:[current nextDateComponents]];
    }
}

- (void)setupDsiplay:(id<TLCalendarDisplay>)display withDateComponent:(NSDateComponents *)comp {
    [display setDateComponents:comp];
    [display setDateAttributes:[self attributesForDisplay:display]];
}

- (NSMutableArray *)attributesForDisplay:(id<TLCalendarDisplay>)display {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:40];
    
    const NSTimeInterval DAY_INTERVAL = 24 * 60 * 60;
    NSInteger days = [display numberOfDays];
    NSDate *date = nil;
    for (NSInteger i = 0; i < days; i++) {
        NSDate *now = date == nil ? [_calendar dateFromComponents:[display firstDay]] : [NSDate dateWithTimeInterval:DAY_INTERVAL sinceDate:date];
        if (date) {
            NSTimeInterval offset = [_calendar.timeZone daylightSavingTimeOffsetForDate:date] - [_calendar.timeZone daylightSavingTimeOffsetForDate:now];
            if (offset != 0) {
                date = [now dateByAddingTimeInterval:offset];
            } else {
                date = now;
            }
        } else {
            date = now;
        }

        NSDateComponents *day = [_calendar components:[display calendarUnit] fromDate:date];
        
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:8];
        [dict setObject:day forKey:kTLDatesAttributeKeyDate];
        
        LunarDate lunar = lunardate_from_solar(day.year, day.month, day.day);
        NSString *lunarDesc = [NSString stringWithUTF8String:(lunar.day == 1 ? lunardate_month(lunar.month) : lunardate_day(lunar.day))];
        [dict setObject:lunarDesc forKey:kTLDatesAttributeKeyLunarDate];
        
        if (_showsSolarTerm) {
            int solar = solarterm_index(day.year, day.month, day.day);
            if (solar >= 0 && solar < 24) {
                [dict setObject:[NSString stringWithCString:solarterm_name(solar) encoding:NSUTF8StringEncoding]
                         forKey:kTLDatesAttributeKeySolarTerm];
            }
        }
        
        if (_chineseFestivals) {
            NSString *fest = [_chineseFestivals objectForKey:[NSNumber numberWithInt:(day.month * 100 + day.day)]];
            if (fest) {
                [dict setObject:fest forKey:kTLDatesAttributeKeyFestivalSolar];
            }
        }
        
        if (_lunarFestivals) {
            NSString *fest = [_lunarFestivals objectForKey:[NSNumber numberWithInt:(lunar.month * 100 + lunar.day)]];
            if (fest) {
                [dict setObject:fest forKey:kTLDatesAttributeKeyFestivalLunar];
            }
        }
        
        [array addObject:dict];
        
        [dict release];

    }
    return array;
}

@end
