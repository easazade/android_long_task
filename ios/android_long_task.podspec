#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint android_long_task.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'android_long_task'
  s.version          = '0.0.1'
  s.summary          = 'android long task is a flutter plugin to run dart code in an android foreground service with simplicity '
  s.description      = <<-DESC
android long task is a flutter plugin to run dart code in an android foreground service with simplicity 
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '8.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
