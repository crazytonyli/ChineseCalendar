#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define TLLog(fmt, ...) NSLog(@"-----> " fmt, ##__VA_ARGS__)

#if __LP64__
#define NSInt   "ld"
#define NSUInt  "lu"
#else
#define NSInt   "d"
#define NSUInt  "u"
#endif /* __LP64__ */

#define LC_BUNDLE_PATH @"/System/Library/WeeAppPlugins/LunarCalendarWidget.bundle"

NS_INLINE NSBundle *LunarCalendarBundle()
{
  static NSBundle *bundle = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
      bundle = [[NSBundle bundleWithPath:LC_BUNDLE_PATH] retain];
  });
  return bundle;
}
