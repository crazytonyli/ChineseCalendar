#import "TLLunarCalendarWeeView.h"
#import "TLMonthWidgetView.h"
#import "TLWeekWidgetView.h"
#import "TLDayWidgetView.h"
#import "../Common/NSCalendarAdditons.h"
#import "../Common/TLFestivalsManager.h"

@interface TLLunarCalendarWeeView(/*PrivateMethod*/)

- (UIImage *)backgroundImage;

- (NSCalendarUnit)calendarUnitForViewType:(TLLunarCalendarWeeViewType)type;

- (void)applyViewType;

@end

@implementation TLLunarCalendarWeeView

- (id)initWithFrame:(CGRect)frame {
    if ( (self = [super initWithFrame:frame]) ) {
        self.viewType = TLLunarCalendarWeeViewMonthType;
        
        _bgImageView = [[UIImageView alloc] initWithImage:[self backgroundImage]];
        [self addSubview:_bgImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        tap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:tap];
        [tap release];
    }
    return self;
}

- (void)dealloc {
    [_calendar release];
    [_calScrollView release];
    [_bgImage release];
    [_bgImageView release];
    [super dealloc];
}

- (void)layoutSubviews {
    CGRect frame = self.frame;
    frame.size.width = self.superview.bounds.size.width;
    self.frame = frame;
    
    _bgImageView.frame = CGRectInset(frame, 2, 0);
    _calScrollView.frame = self.bounds;
}

#pragma mark - Public methods

- (TLCalendarScrollView *)calendarView {
    return _calScrollView;
}

- (void)setViewType:(TLLunarCalendarWeeViewType)viewType {
    if (_viewType != viewType) {
        _viewType = viewType;
        
        [self applyViewType];
    }
}

- (TLLunarCalendarWeeViewType)viewType {
    return _viewType;
}

- (void)setupCalendarView {
    if (_bgImageView.superview) {
        [_bgImageView removeFromSuperview];
        [_bgImageView release];
        _bgImageView = nil;
    }
    if (_calScrollView == nil) {
        _calScrollView = [[TLCalendarScrollView alloc] initWithFrame:self.bounds views:nil];
        _calScrollView.chineseFestivals = [[TLFestivalsManager sharedInstance] chineseFestivals];
        _calScrollView.lunarFestivals = [[TLFestivalsManager sharedInstance] lunarFestivals];
        [self addSubview:_calScrollView];
        [self applyViewType];
    }
}

#pragma mark - Actions

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    if (tap.state == UIGestureRecognizerStateEnded) {
        [_calScrollView displayCurrentDateWithAnimation:YES];
    }
}

#pragma mark - Private methods

- (UIImage *)backgroundImage {
    if (_bgImage == nil) {
        UIImage *bgImg = [UIImage imageWithContentsOfFile:@"/System/Library/WeeAppPlugins/StocksWeeApp.bundle/WeeAppBackground.png"];
        _bgImage = [[bgImg stretchableImageWithLeftCapWidth:floorf(bgImg.size.width / 2.f) topCapHeight:floorf(bgImg.size.height / 2.f)] retain];
    }
    return _bgImage;
}

- (NSCalendarUnit)calendarUnitForViewType:(TLLunarCalendarWeeViewType)type {
    NSCalendarUnit unit = 0;
    switch (type) {
        case TLLunarCalendarWeeViewMonthType:
            unit = (NSYearCalendarUnit | NSMonthCalendarUnit);
            break;
        case TLLunarCalendarWeeViewWeekType:
            unit = (NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekOfYearCalendarUnit);
            break;
        default:
            break;
    }
    return unit;
}

- (void)applyViewType {
    if (_calScrollView) {
        Class cls = NULL;
        switch (_viewType) {
            case TLLunarCalendarWeeViewMonthType:
                cls = [TLMonthWidgetView class];
                break;
            case TLLunarCalendarWeeViewWeekType:
                cls = [TLWeekWidgetView class];
                break;
            case TLLunarCalendarWeeViewDayType:
                cls = [TLDayWidgetView class];
                break;
            default:
                break;
        }
        
        if (cls) {
            TLWidgetView *prev = [[cls alloc] initWithFrame:CGRectZero];
            TLWidgetView *cur = [[cls alloc] initWithFrame:CGRectZero];
            TLWidgetView *next = [[cls alloc] initWithFrame:CGRectZero];
            prev.backgroundImage = _bgImage;
            cur.backgroundImage = _bgImage;
            next.backgroundImage = _bgImage;
            
            _calScrollView.views = [NSArray arrayWithObjects:prev, cur, next, nil];
            
            [prev release];
            [cur release];
            [next release];
        }
    }
}

@end
