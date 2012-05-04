#import "LCWSettingsController.h"

@interface LCWPColorController : LCWSettingsController{
}
@end

@implementation LCWPColorController

- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"ColorSettings" target:self] retain];
	}
	return _specifiers;
}

#pragma mark - Setters

- (void)setCustomizeWeekdayTextColor:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
    
}

- (void)setCustomizeWeekendTextColor:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
    
}

- (void)setCustomizeTodayTextColor:(NSNumber *)value forSpecifier:(PSSpecifier *)specifier {
    
}

@end

// vim:ft=objc
