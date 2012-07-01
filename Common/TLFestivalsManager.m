//
//  TLFestivalsManager.m
//  ChineseCalendar
//
//  Created by Tony Li on 6/6/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLFestivalsManager.h"

#define AddFestival(dict, name, month, day) [(dict) setObject:(name) forKey:[NSNumber numberWithInt:((month) * 100 + (day))]]

@implementation TLFestivalsManager

static TLFestivalsManager *sInstance = nil;

+ (TLFestivalsManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sInstance = [[TLFestivalsManager alloc] init];
    });
    return sInstance;
}

- (void)dealloc {
    sInstance = nil;
    [_chineseFestivals release];
    [_lunarFestivals release];
    [_westernFestivals release];
    
    [super dealloc];
}

- (oneway void)release {
    // Empty
}

- (id)retain {
    // Empty
    return self;
}

- (id)autorelease {
    // Empty
    return self;
}

#pragma mark - Public methods

- (NSDictionary *)chineseFestivals {
    if (_chineseFestivals == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        AddFestival(dict, @"元旦", 1, 1);
        AddFestival(dict, @"情人节", 2, 14);
        AddFestival(dict, @"愚人节", 4, 1);
        AddFestival(dict, @"劳动节", 5, 1);
        AddFestival(dict, @"青年节", 5, 4);
        AddFestival(dict, @"儿童节", 6, 1);
        AddFestival(dict, @"建军节", 8, 1);
        AddFestival(dict, @"教师节", 9, 10);
        AddFestival(dict, @"国庆", 10, 1);
        AddFestival(dict, @"平安夜", 12, 24);
        AddFestival(dict, @"圣诞节", 12, 25);
        _chineseFestivals = [dict copy];
    }
    return _chineseFestivals;
}

- (NSDictionary *)lunarFestivals {
    if (_lunarFestivals == nil) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
        AddFestival(dict, @"春节", 1, 1);
        AddFestival(dict, @"元宵", 1, 15);
        AddFestival(dict, @"端午", 5, 5);
        AddFestival(dict, @"七夕", 7, 7);
        AddFestival(dict, @"中元", 7, 15);
        AddFestival(dict, @"中秋", 8, 15);
        AddFestival(dict, @"重阳", 9, 9);
        AddFestival(dict, @"腊八", 12, 8);
        AddFestival(dict, @"小年", 12, 23);
        AddFestival(dict, @"除夕", 12, 30);
        _lunarFestivals = [dict copy];
    }
    return _lunarFestivals;
}

- (NSDictionary *)westernFestivals {
    if (_westernFestivals == nil) {
        // ...
    }
    return _westernFestivals;
}

@end
