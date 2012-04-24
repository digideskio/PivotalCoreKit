Pod::Spec.new do |s|
  s.name     = 'PivotalCoreKit'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.summary  = 'Shared library and test code for iOS projects.'
  s.homepage = 'https://github.com/pivotal/PivotalCoreKit'
  s.author   = { 'Pivotal Labs' => 'http://pivotallabs.com' }
  s.source   = { :git => 'git://github.com/jeanregisser/PivotalCoreKit.git' }
  s.platform = :ios
  
  s.clean_paths = FileList['*'].exclude(/(CoreLib|UICoreLib|SpecHelperLib|README.markdown)$/)

  s.subspec 'CoreLib' do |core|
    core.summary      = 'Shared production code.'
    core.source_files = 'CoreLib/**/*.{h,m}'
    core.libraries    = 'xml2'
    core.xcconfig     = { 'HEADER_SEARCH_PATHS' => '$(SDKROOT)/usr/include/libxml2' }
  end

  s.subspec 'UICoreLib' do |uicore|
    uicore.summary      = 'Shared UI production code.'
    uicore.source_files = 'UICoreLib/**/*.{h,m}'
    uicore.frameworks   = 'UIKit', 'CoreText'
  end
  
  s.subspec 'SpecHelperLib' do |spec_helper|
    spec_helper.summary      = 'Shared spec code.'
    spec_helper.source_files = 'SpecHelperLib/**/*.{h,m}'
    spec_helper.frameworks   = 'UIKit'
    spec_helper.dependency 'Cedar'
  end
  
end
