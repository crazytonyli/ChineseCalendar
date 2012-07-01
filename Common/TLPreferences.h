//
//  TLPreferences.h
//  ChineseCalendar
//
//  Created by Tony Li on 6/8/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import <Foundation/Foundation.h>

NSNumber *TLPreferenceNumberForKey(NSString *key);

NSString *TLPreferenceStringForKey(NSString *key);

int TLPreferecneIntForKey(NSString *key, int defValue);

BOOL TLPreferenceBoolForKey(NSString *key, BOOL defValue);
