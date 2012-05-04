#import <UIKit/UIKit.h>
#import "../Common/TLCalendarScrollView.h"

@class NSCalendar;

typedef enum {
    TLLunarCalendarWeeViewWeekType = 0,
    TLLunarCalendarWeeViewMonthType,
    TLLunarCalendarWeeViewDayType
} TLLunarCalendarWeeViewType;

@interface TLLunarCalendarWeeView : UIView {
    TLCalendarScrollView *_calScrollView;
    UIImage *_bgImage;
    UIImageView *_bgImageView;
    
    TLLunarCalendarWeeViewType _viewType;
    
    NSDateComponents *_dateComponents;
    NSDateComponents *_weekDiff;
    NSDateComponents *_monthDiff;
    NSCalendar *_calendar;
}

@property (nonatomic, readonly) TLCalendarScrollView *calendarView;

@property (nonatomic, assign) TLLunarCalendarWeeViewType viewType;

- (void)setupCalendarView;

@end
