//
//  TLMonthWidgetView.h
//  Calendar
//
//  Created by Tony Li on 4/6/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "../Common/TLCalendarDisplay.h"
#import "TLWidgetView.h"

typedef enum {
    TLMonthWidgetViewCompactStyle,
    TLMonthWidgetViewLooseStyle,
} TLMonthWidgetViewStyle;

@interface TLMonthWidgetView : TLWidgetView<TLCalendarDisplay> {
    CGSize _dayCellSize;
}

+ (CGFloat)minHeightForStyle:(TLMonthWidgetViewStyle)style fullColumns:(BOOL)full;

@property (nonatomic, assign) TLMonthWidgetViewStyle style;
@property (nonatomic, assign) int rowCount;

@end
