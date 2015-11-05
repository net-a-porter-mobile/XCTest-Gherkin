#
# Be sure to run `pod lib lint XCTest-Gherkin.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "XCTest-Gherkin"
  s.version          = "0.1.0"
  s.summary          = "Gherkin style tests"
  s.description      = <<-DESC
Adds Gherkin syntax to XCTestCase
                       DESC

  s.homepage         = "https://github.com/net-a-porter-mobile/XCTest-Gherkin"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = { :type => 'Apache', :file => 'LICENSE' }
  s.author           = { "Sam Dean" => "sam.dean@net-a-porter.com" }
  s.source           = { :git => "https://github.com/net-a-porter-mobile/XCTest-Gherkin.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'XCTest-Gherkin' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'XCTest'
  # s.dependency 'AFNetworking', '~> 2.3'
end
