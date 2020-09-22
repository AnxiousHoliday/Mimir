#
# Be sure to run `pod lib lint Mimir.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Mimir'
  s.version          = '0.0.2'
  s.summary          = 'Mimir is a logging framework that is intended for high usage apps.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Mimir is a logging framework that is intended for high usage apps that require constant logging while maintaining logs in a small sized file. 
This is done by logging to 2 separate text files - a truncated and an extended text file. The most recent logs will be saved fully to the extended text file, while the older logs will be in the truncated text file which limits the length of each log by the configured size.
                       DESC

  s.homepage         = 'https://github.com/amereid/Mimir'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Amer Eid' => 'amereid92@gmail.com' }
  s.source           = { :git => 'https://github.com/amereid/Mimir.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_versions = '5.0'
  s.ios.deployment_target = '9.0'

  s.source_files = 'Mimir/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Mimir' => ['Mimir/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
