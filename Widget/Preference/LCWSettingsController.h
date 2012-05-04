#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

#import <UIKit/UIKit.h>

@interface LCWSettingsController : PSListController {
    NSUserDefaults *_userDefaults;
}
- (NSUserDefaults *)userDefaults;
@end

