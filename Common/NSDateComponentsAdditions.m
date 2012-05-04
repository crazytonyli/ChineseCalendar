//
//  NSDateComponentsAdditions.m
//  Calendar
//
//  Created by Tony Li on 3/19/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "NSDateComponentsAdditions.h"

@implementation NSDateComponents(TLLunarCalendarAdditions)

- (BOOL)isSameDayWithComponents:(NSDateComponents *)components {
    return self.year == components.year && self.month == components.month && self.day == components.day;
}

@end
