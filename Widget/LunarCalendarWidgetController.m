#import "BBWeeAppController-Protocol.h"
#import "TLMonthWidgetView.h"
#import "TLWeekWidgetView.h"
#import "TLDayWidgetView.h"
#import "TLLunarCalendarWeeView.h"
#import "../Common/TLCalendarScrollView.h"
#import "../Common/NSCalendarAdditons.h"
#import "../Common/TLPreferences.h"
#import "../Common/TLFestivalsManager.h"
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
        calView.chineseFestivals = [[TLFestivalsManager sharedInstance] chineseFestivals];
        calView.lunarFestivals = [[TLFestivalsManager sharedInstance] lunarFestivals];
        calView.showsSolarTerm = YES;
        
        int fow = TLPreferecneIntForKey(@"firstDayOfWeek", 1);
        if (fow != [[NSCalendar sharedCalendar] firstWeekday]) {
            [[NSCalendar sharedCalendar] setFirstWeekday:fow];
            [calView setNeedsLayoutWidgets];
        }
        
        TLLunarCalendarWeeViewType type = TLPreferecneIntForKey(@"viewType", TLLunarCalendarWeeViewMonthType);
        [_view setViewType:type];
        
        if (type == TLLunarCalendarWeeViewMonthType) {
            NSArray *views = calView.views;
            TLMonthWidgetView *current = [views objectAtIndex:1];
            TLMonthWidgetViewStyle style = TLPreferecneIntForKey(@"layoutStyle", TLMonthWidgetViewLooseStyle);
            int rowCount = TLPreferecneIntForKey(@"monthRows", 6);
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
    switch (TLPreferecneIntForKey(@"viewType", TLLunarCalendarWeeViewMonthType)) {
        case TLLunarCalendarWeeViewDayType:
            height = [TLDayWidgetView minHeight];
            break;
        case TLLunarCalendarWeeViewWeekType:
            height = [TLWeekWidgetView minHeight];
            break;
        case TLLunarCalendarWeeViewMonthType:
            height = [TLMonthWidgetView minHeightForStyle:TLPreferecneIntForKey(@"layoutStyle", TLMonthWidgetViewLooseStyle)
                                              fullColumns:(TLPreferecneIntForKey(@"monthRows", 6) == 6)];
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

@end
