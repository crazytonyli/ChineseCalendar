//
//  TLLunarDate.h
//  Calendar
//
//  Created by Tony Li on 2/24/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLLunarDate : NSObject {
    int lunarYear, lunarMonth, lunarDay;
    
    NSDateComponents *_solarDateComponents;
}

+ (NSRange)supportedYearRange;

@property (nonatomic, copy) NSDateComponents *solarDateComponent;

@property (nonatomic, readonly) int lunarYear;
@property (nonatomic, readonly) int lunarMonth;
@property (nonatomic, readonly) int lunarDay;
@property (nonatomic, readonly) BOOL isLeapMonth;

- (id)initWithSolarDateComponents:(NSDateComponents *)dateComponents;

- (NSString *)chineseDay;

- (NSString *)chineseMonth;

- (NSString *)chineseYear;

- (NSString *)attribution;

@end
