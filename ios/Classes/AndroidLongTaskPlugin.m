#import "AndroidLongTaskPlugin.h"
#if __has_include(<android_long_task/android_long_task-Swift.h>)
#import <android_long_task/android_long_task-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "android_long_task-Swift.h"
#endif

@implementation AndroidLongTaskPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftAndroidLongTaskPlugin registerWithRegistrar:registrar];
}
@end
