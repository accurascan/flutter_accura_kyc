#import "FlutterAccuraKycPlugin.h"
#if __has_include(<flutter_accura_kyc/flutter_accura_kyc-Swift.h>)
#import <flutter_accura_kyc/flutter_accura_kyc-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_accura_kyc-Swift.h"
#endif

@implementation FlutterAccuraKycPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterAccuraKycPlugin registerWithRegistrar:registrar];
}
@end
