//
//  TLCalendarScrollView.m
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLCalendarScrollView.h"
#import "NSCalendarAdditons.h"
#import "../Widget/TLWidgetView.h"
#import "TLLunarDate.h"

@interface TLCalendarScrollView(/*PrivateMethods*/)<TLWidgetViewDataSource>

- (void)layoutWidgets;

@end

@implementation TLCalendarScrollView

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
        
        NSBundle *mainBundle = [NSBundle bundleForClass:[self class]];
        NSString *lunar = [mainBundle pathForResource:@"festival-lunar" ofType:@"plist"];
        NSString *solar = [mainBundle pathForResource:@"festival-solar" ofType:@"plist"];
        _lunarFestival = [[NSDictionary alloc] initWithContentsOfFile:lunar];
        _solarFestival = [[NSDictionary alloc] initWithContentsOfFile:solar];
    }
    return self;
}

- (void)dealloc {
    [_views release];
    [_calendar release];
    [_lunarFestival release];
    [_lunarFestival release];
    [_solarFestival release];
    
    [super dealloc];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.contentSize = CGSizeMake(frame.size.width * 3, frame.size.height);
    self.contentOffset = CGPointMake(frame.size.width, 0);
    [[_views objectAtIndex:0] setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [[_views objectAtIndex:1] setFrame:CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height)];
    [[_views objectAtIndex:2] setFrame:CGRectMake(frame.size.width * 2, 0, frame.size.width, frame.size.height)];
    [[_views objectAtIndex:1] setNeedsDisplay];
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
                TLWidgetView *view = [views objectAtIndex:i];
                frame.origin.x = i * frame.size.width;
                view.userInteractionEnabled = NO;
                view.dataSource = self;
                [self addSubview:view];
            }
            
            _needLayoutWidgets = YES;
        }
    }
}

- (void)displayCurrentDateWithAnimation:(BOOL)animated {
    if (_views) {
        id<TLCalendarDisplay> current = [_views objectAtIndex:1];
        NSDateComponents *comp = [_calendar components:[current calendarUnit] fromDate:[NSDate date]];
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
            [targetView setDateComponents:comp];
            [self scrollRectToVisible:targetView.frame animated:animated];
            
            if (!animated) {
                [self layoutWidgets];
            }
        } else {
            [[_views objectAtIndex:1] setNeedsDisplay];
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        _needLayoutWidgets = YES;
        [self setNeedsLayout];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    _needLayoutWidgets = YES;
    [self setNeedsLayout];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    _needLayoutWidgets = YES;
    [self setNeedsLayout];
}

#pragma mark - TLWidgetView data source

- (NSString *)widgetView:(TLWidgetView *)view lunarFestivalForDate:(TLLunarDate *)date {
    return [_lunarFestival objectForKey:[NSString stringWithFormat:@"%02d%02d", date.lunarMonth, date.lunarDay]];
}

- (NSString *)widgetView:(TLWidgetView *)view solarFestivalForDateComponents:(NSDateComponents *)comp {
    NSString *key = [NSString stringWithFormat:@"%02d%02d", comp.month, comp.day];
    return [_solarFestival objectForKey:key];
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
        
        [current setDateComponents:currentComponents];
        [prev setDateComponents:[current previousDateComponents]];
        [next setDateComponents:[current nextDateComponents]];
        
        [current setNeedsLayout];
    }
}

@end
