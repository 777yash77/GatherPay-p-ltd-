//
//  Generated file. Do not edit.
//

// clang-format off

#import "GeneratedPluginRegistrant.h"

#if __has_include(<flutter_contacts/FlutterContactsPlugin.h>)
#import <flutter_contacts/FlutterContactsPlugin.h>
#else
@import flutter_contacts;
#endif

#if __has_include(<shared_preferences_foundation/SharedPreferencesPlugin.h>)
#import <shared_preferences_foundation/SharedPreferencesPlugin.h>
#else
@import shared_preferences_foundation;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [FlutterContactsPlugin registerWithRegistrar:[registry registrarForPlugin:@"FlutterContactsPlugin"]];
  [SharedPreferencesPlugin registerWithRegistrar:[registry registrarForPlugin:@"SharedPreferencesPlugin"]];
}

@end
