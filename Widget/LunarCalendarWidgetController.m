#import "BBWeeAppController-Protocol.h"
#import "TLMonthWidgetView.h"
#import "TLWeekWidgetView.h"
#import "TLDayWidgetView.h"
#import "TLLunarCalendarWeeView.h"
#import "../Common/TLCalendarScrollView.h"
#import "../Common/NSCalendarAdditons.h"
#include <objc/runtime.h>

#define APPID_CFSTR CFSTR("tonyli.lunarcalendar.widget")

#define BG_VIEW_TAG 100

@interface NSObject(SupressWarning)

+ (id)sharedInstance;

- (id)listView;
@end

@interface LunarCalendarWidgetController: NSObject <BBWeeAppController> {
	TLLunarCalendarWeeView *_view;
}

@property (nonatomic, readonly) UIView *view;

- (CGFloat)viewWidth;

- (void)displayView;

- (TLLunarCalendarWeeViewType)viewType;
- (TLMonthWidgetViewStyle)monthViewStyle;
- (int)monthViewRowCount;
- (NSUInteger)firstDayOfWeek;

@end

@implementation LunarCalendarWidgetController

- (id)init {
	if((self = [super init]) != nil) {
	} return self;
}

- (void)dealloc {
	[_view release];
	[super dealloc];
}

- (void)loadFullView {
    if (_view.calendarView == nil) {
        [_view setupCalendarView];
    }
    [self displayView];
}

- (UIView *)view {
    if (_view == nil) {
        _view = [[TLLunarCalendarWeeView alloc] initWithFrame:CGRectMake(0, 0, [self viewWidth], [self viewHeight])];
    }
    return _view;
}

- (CGFloat)viewWidth {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            return 320.0f;
        } else {
            return 480.0f;
        }
    } else {
        return 480.0f;
    }
}

- (void)displayView {
    TLCalendarScrollView *calView = _view.calendarView;
    if (calView) {
        int fow = [self firstDayOfWeek];
        if (fow != [[NSCalendar sharedCalendar] firstWeekday]) {
            [[NSCalendar sharedCalendar] setFirstWeekday:fow];
            [calView setNeedsLayoutWidgets];
        }
        
        TLLunarCalendarWeeViewType type = [self viewType];
        [_view setViewType:type];
        
        if (type == TLLunarCalendarWeeViewMonthType) {
            NSArray *views = calView.views;
            TLMonthWidgetView *current = [views objectAtIndex:1];
            TLMonthWidgetViewStyle style = [self monthViewStyle];
            int rowCount = [self monthViewRowCount];
            if (style != [current style]) {
                for (TLMonthWidgetView *view in views) {
                    view.style = style;
                    view.rowCount = rowCount;
                }
                [current setNeedsLayout];
            }
        }
        
        [calView setNeedsLayoutWidgets];
    }
}

- (float)viewHeight {
    CGFloat height = 71.0f;
    switch ([self viewType]) {
        case TLLunarCalendarWeeViewDayType:
            height = [TLDayWidgetView minHeight];
            break;
        case TLLunarCalendarWeeViewWeekType:
            height = [TLWeekWidgetView minHeight];
            break;
        case TLLunarCalendarWeeViewMonthType:
            height = [TLMonthWidgetView minHeightForStyle:[self monthViewStyle] fullColumns:([self monthViewRowCount] == 6)];
            break;
        default:
            break;
    }
    return height;
}

- (void)viewWillAppear {
    _view.frame = CGRectMake(0, 0, [self viewWidth], [self viewHeight]);
}

- (void)willRotateToInterfaceOrientation:(int)interfaceOrientation {
    _view.frame = CGRectMake(0, 0, [self viewWidth], [self viewHeight]);
}

- (TLLunarCalendarWeeViewType)viewType {
    CFStringRef appId = APPID_CFSTR;
    CFPreferencesSynchronize(appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("viewType"), appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        int type = TLLunarCalendarWeeViewMonthType;
        CFNumberGetValue(value, kCFNumberIntType, &type);
        CFRelease(value);
        return type;
    } else {
        return TLLunarCalendarWeeViewMonthType;
    }
}

- (TLMonthWidgetViewStyle)monthViewStyle {
    CFStringRef appId = APPID_CFSTR;
    CFPreferencesSynchronize(appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("layoutStyle"), appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        int style = TLMonthWidgetViewLooseStyle;
        CFNumberGetValue(value, kCFNumberIntType, &style);
        CFRelease(value);
        return style;
    } else {
        return TLMonthWidgetViewLooseStyle;
    }
}

- (int)monthViewRowCount {
    CFStringRef appId = APPID_CFSTR;
    CFPreferencesSynchronize(appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("monthRows"), appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        int style = 6;
        CFNumberGetValue(value, kCFNumberIntType, &style);
        CFRelease(value);
        return style;
    } else {
        return 6;
    }
}

- (NSUInteger)firstDayOfWeek {
    CFStringRef appId = APPID_CFSTR;
    CFPreferencesSynchronize(appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue(CFSTR("firstDayOfWeek"), appId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    if (value) {
        int fow = 1;
        CFNumberGetValue(value, kCFNumberIntType, &fow);
        if (fow < 1 || fow > 7) {
            fow = 1;
        }
        CFRelease(value);
        return fow;
    } else {
        return 1;
    }
}

@end
