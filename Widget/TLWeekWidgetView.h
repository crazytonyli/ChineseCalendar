//
//  TLWeekWidgetView.h
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLWidgetView.h"
#import "../Common/TLCalendarDisplay.h"

@interface TLWeekWidgetView : TLWidgetView<TLCalendarDisplay> {
}

+ (CGFloat)minHeight;

@end
