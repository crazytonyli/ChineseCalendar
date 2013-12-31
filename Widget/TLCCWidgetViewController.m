#import "LunarCalendarWidgetController.h"
#import "SBUIWidgetViewController.h"

@interface NSObject(SBWidgetHostDelegate)

- (void)widget:(id)arg1 didUpdatePreferredSize:(struct CGSize)arg2;

@end

@interface TLCCWidgetViewController : _SBUIWidgetViewController {
    LunarCalendarWidgetController *_controller;
}
@end

@implementation TLCCWidgetViewController

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ( (self = [super initWithNibName:nibName bundle:nibBundle]) ) {
        _controller = [[LunarCalendarWidgetController alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_controller release];
    _controller = nil;
    [super dealloc];
}

- (void)loadView
{
    self.view = [_controller view];
}

- (CGSize)preferredViewSize
{
    return CGSizeMake([_controller viewWidth], [_controller viewHeight]);
}

- (void)hostDidPresent
{
    [super hostDidPresent];
    [_controller loadFullView];

    if (self.view.bounds.size.height != [_controller viewHeight]) {
        [[[self widgetHost] delegate] widget:[self widgetHost] didUpdatePreferredSize:[self preferredViewSize]];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [_controller willRotateToInterfaceOrientation:toInterfaceOrientation];
}

@end
