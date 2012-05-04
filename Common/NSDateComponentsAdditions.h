//
//  NSDateComponentsAdditions.h
//  Calendar
//
//  Created by Tony Li on 3/19/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateComponents(TLLunarCalendarAdditions)

- (BOOL)isSameDayWithComponents:(NSDateComponents *)components;

@end
