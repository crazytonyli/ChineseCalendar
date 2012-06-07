//
//  TLFestivalsManager.h
//  ChineseCalendar
//
//  Created by Tony Li on 6/6/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TLFestivalsManager : NSObject

+ (TLFestivalsManager *)sharedInstance;

- (NSDictionary *)chineseFestivals;
- (NSDictionary *)lunarFestivals;

@end
