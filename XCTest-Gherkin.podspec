#
# Be sure to run `pod lib lint XCTest-Gherkin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XCTest-Gherkin"
  s.version          = "0.9.0"
  s.summary          = "Gherkin style tests"
  s.description      = <<-DESC
Adds Gherkin syntax to XCTestCase
                       DESC

  s.homepage         = "https://github.com/net-a-porter-mobile/XCTest-Gherkin"
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { "Sam Dean" => "sam.dean@net-a-porter.com" }
  s.source           = { :git => "https://github.com/net-a-porter-mobile/XCTest-Gherkin.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.default_subspec = 'Core'
  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.10.0'
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'NO' }

  s.subspec 'Core' do |ss|
    ss.source_files = 'Pod/Core/**/*'
  end

  s.subspec 'Native' do |ss|
    ss.source_files = 'Pod/Native/**/*'

    ss.dependency 'XCTest-Gherkin/Core'
  end

  s.frameworks = 'XCTest'
end
