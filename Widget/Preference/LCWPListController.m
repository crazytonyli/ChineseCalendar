#import "LCWSettingsController.h"

@interface LCWPListController : LCWSettingsController<UIActionSheetDelegate> {
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
    return @"1.1";
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

- (void)donate {
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://me.alipay.com/cyntin"]];
}

- (void)buyPro {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if (window) {
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"购买Pro版" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从淘宝购买", @"从Cydia购买", nil];
        [sheet showInView:window];
        [sheet release];
    }
}

- (void)buyViaCydia {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/com.crazytonyli.chinesecalendarpro"]];
}

- (void)buyViaTaobao {
    UIApplication *app = [UIApplication sharedApplication];
    NSURL *clientURL = [NSURL URLWithString:@"taobao://item.taobao.com/item.htm?id=18270676555"];
    if ([app canOpenURL:clientURL]) {
           [app openURL:clientURL];
    } else {
        [app openURL:[NSURL URLWithString:@"http://item.taobao.com/item.htm?id=18270676555"]];
    }
}

#pragma mark - ActionSheet delegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self buyViaTaobao];
    } else if (buttonIndex == 1) {
        [self buyViaCydia];
    }
}

@end

// vim:ft=objc
