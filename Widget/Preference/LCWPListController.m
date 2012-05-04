#import "LCWSettingsController.h"

@interface LCWPListController : LCWSettingsController {
}
@end

@implementation LCWPListController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"LunarCalendarWidgetPreference" target:self] retain];
	}
	return _specifiers;
}

#pragma mark - Overrides

-(void)viewDidBecomeVisible {
    [super viewDidBecomeVisible];

    int viewType = [[self userDefaults] integerForKey:@"viewType"];
    [[self specifierForID:@"layoutStyleSpecifier"] setProperty:[NSNumber numberWithBool:(viewType  == 1)] forKey:@"enabled"];
    [self reloadSpecifierID:@"layoutStyleSpecifier" animated:YES];
}

#pragma mark - Getters

- (NSString *)widgetVersion {
    return @"0.1";
}

- (NSString *)username {
    return @"@crazytonyli";
}

#pragma mark - Setters

- (void)setViewType:(NSNumber *)viewType forSpecifier:(PSSpecifier *)s {
    [self setPreferenceValue:viewType specifier:s];

    [[self specifierForID:@"layoutStyleSpecifier"] setProperty:[NSNumber numberWithBool:([viewType integerValue] == 1)] forKey:@"enabled"];
    [self reloadSpecifierID:@"layoutStyleSpecifier" animated:YES];
}

#pragma mark - Actions

- (void)feedback {
    NSString *url = [NSString stringWithFormat:@"mailto:crazygemini.lee@gmail.com?subject=Chinese Calendar Feedback (Version: %@)", [self widgetVersion]];
    url = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

@end

// vim:ft=objc
