//
//  NSCalendarAdditons.h
//  Calendar
//
//  Created by Tony Li on 4/7/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCalendar(TLLunarCalendarAdditions)

+ (id)sharedCalendar;

- (NSArray *)chineseWeekdaysWithPrefix:(NSString *)prefix;

@end
