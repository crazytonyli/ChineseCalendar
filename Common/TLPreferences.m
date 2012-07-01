//
//  TLPreferences.m
//  ChineseCalendar
//
//  Created by Tony Li on 6/8/12.
//  Copyright (c) 2012 Tony Li. All rights reserved.
//

#import "TLPreferences.h"

const CFStringRef _sAppId = CFSTR("tonyli.lunarcalendar.widget");

int hextoint(const char* xs, unsigned int* result);

NSNumber *TLPreferenceNumberForKey(NSString *key) {
    CFPreferencesSynchronize(_sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue((CFStringRef)key, _sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSNumber *ret = nil;
    if (value) {
        ret = CFGetTypeID(value) == CFNumberGetTypeID() ? [[(NSNumber *)value copy] autorelease] : nil;
        CFRelease(value);
    }
    return ret;
}

NSString *TLPreferenceStringForKey(NSString *key) {
    CFPreferencesSynchronize(_sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue((CFStringRef)key, _sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    NSString *ret = nil;
    if (value) {
        ret = CFGetTypeID(value) == CFStringGetTypeID() ? [[(NSString *)value copy] autorelease] : nil;
        CFRelease(value);
    }
    return ret;
}

int TLPreferecneIntForKey(NSString *key, int defValue) {
    NSNumber *value = TLPreferenceNumberForKey(key);
    return value ? [value intValue] : defValue;
}

BOOL TLPreferenceBoolForKey(NSString *key, BOOL defValue) {
    CFPreferencesSynchronize(_sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    CFPropertyListRef value = CFPreferencesCopyValue((CFStringRef)key, _sAppId, kCFPreferencesCurrentUser, kCFPreferencesAnyHost);
    BOOL ret = defValue;
    if (value) {
        ret = CFGetTypeID(value) == CFBooleanGetTypeID() ? CFBooleanGetValue(value) : defValue;
        CFRelease(value);
    }
    return ret;
}
