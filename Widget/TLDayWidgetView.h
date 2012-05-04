//
//  TLDayWidgetView.h
//  Calendar
//
//  Created by Tony Li on 4/29/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLWidgetView.h"
#import "../Common/TLCalendarDisplay.h"

@interface TLDayWidgetView : TLWidgetView<TLCalendarDisplay>

+ (CGFloat)minHeight;

@end
