#import <UIKit/UIKit.h>
#import "BBWeeAppController-Protocol.h"

@class TLLunarCalendarWeeView;

@interface LunarCalendarWidgetController: NSObject <BBWeeAppController> {
	TLLunarCalendarWeeView *_view;
}

@property (nonatomic, readonly) UIView *view;

- (CGFloat)viewWidth;
- (CGFloat)viewHeight;

@end
