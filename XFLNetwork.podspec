#
# Be sure to run `pod lib lint XFLNetwork.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'XFLNetwork'
  s.version          = '0.1.0'
  s.summary          = '封装基于Alamofire的常用请求Api'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  封装基于Alamofire的常用请求Api,方便项目中使用
                       DESC

  s.homepage         = 'https://github.com/xiaofulon/XFLNetwork'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'xiaofulon' => '13559487161@139.com' }
  s.source           = { :git => 'https://github.com/xiaofulon/XFLNetwork.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '5'

  s.source_files = 'XFLNetwork/Classes/**/*'
  
  # s.resource_bundles = {
  #   'XFLNetwork' => ['XFLNetwork/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'Alamofire', '5.0.0-rc.3'
  
end
