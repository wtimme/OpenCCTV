#
# Be sure to run `pod lib lint OSMSwift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OSMSwift'
  s.version          = '0.1.0'
  s.summary          = 'A Swift client framework for the OpenStreetMap API v0.6'

  s.description      = <<-DESC
The framework aims to allow for easy editing of OpenStreetMap data.
                       DESC

  s.homepage         = 'https://github.com/wtimme/OSMSwift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'wtimme' => 'wtimme@users.noreply.github.com' }
  s.source           = { :git => 'https://github.com/wtimme/OSMSwift.git', :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'

  s.source_files = 'OSMSwift/Classes/**/*'
  
  # s.resource_bundles = {
  #   'OSMSwift' => ['OSMSwift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 4.7.0'
end
