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

- (void)setDateAttributes:(NSArray *)attributes;
- (NSArray *)dateAttributes;

- (void)setEvents:(NSDictionary *)dictionary;
- (NSDictionary *)events;

- (NSDateComponents *)previousDateComponents;
- (NSDateComponents *)nextDateComponents;

- (NSDateComponents *)dateComponentsForCurrentDate;

- (NSComparisonResult)compareWithDateComponents:(NSDateComponents *)target;

- (NSCalendarUnit)calendarUnit;

- (NSDateComponents *)firstDay;
- (NSInteger)numberOfDays;

- (NSUInteger)dayIndexAtPoint:(CGPoint)point;

@end
