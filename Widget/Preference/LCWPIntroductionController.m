#import "LCWSettingsController.h"

@interface LCWPIntroductionController : LCWSettingsController
@end

@implementation LCWPIntroductionController

- (id)specifiers {
    if(_specifiers == nil) {
        _specifiers = [[self loadSpecifiersFromPlistName:@"Introduction" target:self] retain];
    }
    return _specifiers;
}

@end
