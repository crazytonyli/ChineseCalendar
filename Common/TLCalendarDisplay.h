//
//  TLCalendarDisplay.h
//  Calendar
//
//  Created by Tony Li on 4/18/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TLCalendarDisplay <NSObject>

- (void)setDateComponents:(NSDateComponents *)comp;
- (NSDateComponents *)dateComponents;

- (NSDateComponents *)previousDateComponents;
- (NSDateComponents *)nextDateComponents;

- (NSDateComponents *)dateComponentsForCurrentDate;

- (NSComparisonResult)compareWithDateComponents:(NSDateComponents *)target;

- (NSCalendarUnit)calendarUnit;

@end
