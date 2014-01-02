#import "../Common.h"

#define IS_PATH_OF_CC(path) [[[path pathComponents] lastObject] isEqualToString:[[LC_BUNDLE_PATH pathComponents] lastObject]]

%hook BBSectionInfo

- (NSString *)pathToWeeAppPluginBundle {
    NSString *path = %orig;
    if (IS_PATH_OF_CC(path)) {
        path = LC_BUNDLE_PATH;
    }

    return path;
}

- (void)setPathToWeeAppPluginBundle:(NSString *)path {
    if (IS_PATH_OF_CC(path)) {
        path = LC_BUNDLE_PATH;
    }

    %orig(path);
}

%end
