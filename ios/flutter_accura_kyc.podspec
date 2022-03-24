#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_accura_kyc.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_accura_kyc'
  s.version          = '0.0.1'
  s.summary          = 'A new flutter plugin project.'
  s.description      = <<-DESC
A new flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  # s.source_files = 'Classes/**/*'
  # s.resources = "Classes/**/*.{png,jpeg,jpg,xib,xcassets,imageset,gif,mp3,storyboard}"
  s.source_files = "Classes/**/*.{h,m,mm,swift}"
  s.resources = "Classes/**/*.{png,jpeg,jpg,xib,xcassets,imageset,gif,mp3,storyboard}"

  s.dependency 'Flutter'
  s.static_framework = true
  # s.dependency "AccuraKYC-Hybrid","3.0.2" 
  s.dependency "AccuraKYC-Hybrid-sim","3.1.1" 
  s.platform = :ios, '12.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
