#import "LCWSettingsController.h"

@implementation LCWSettingsController

- (void)dealloc {
    [_userDefaults release];
    [super dealloc];
}

- (NSUserDefaults *)userDefaults {
    if (_userDefaults == nil) {
        //_userDefaults = [[NSUserDefaults alloc] initWithUser:@"tonyli.lunarcalendar.widget"];
        _userDefaults = [[NSUserDefaults standardUserDefaults] retain];
    } 
    return _userDefaults;
}

-(void)setPreferenceValue:(id)value specifier:(id)specifier {
    [super setPreferenceValue:value specifier:specifier];
    NSString *key = [specifier propertyForKey:@"key"];
    if (key) {
        static NSString *APP_DOMAIN = @"tonyli.lunarcalendar.widget";
        NSMutableDictionary *pref = [NSMutableDictionary dictionaryWithDictionary:[[self userDefaults] persistentDomainForName:APP_DOMAIN]];
        [pref setObject:value forKey:key];
        [_userDefaults setPersistentDomain:pref forName:APP_DOMAIN];
        [_userDefaults synchronize];
    }
}

@end

// vim:ft=objc
