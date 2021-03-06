#
# Be sure to run `pod lib lint DGDownloadManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DGDownloadManager'
  s.version          = '1.1.13'
  s.summary          = 'DGDownloadManager summary'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/liudiange/DGDownloadManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'shaoyeliudiange@163.com' => 'hzycode@163.com' }
  s.source           = { :git => 'https://github.com/liudiange/DGDownloadManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'DGDownloadManager/Classes/**/*'
  #s.subspec 'DGBackgroudDownloadManagers' do |sb|
    #sb.source_files = 'DGDownloadManager/Classes/DGBackgroudDownloadManagers/**/*'
    #sb.dependency "AFNetworking", "~> 3.1.0"
  #end

  #s.subspec 'DGDownloadManagers' do |ss|
    #ss.source_files = 'DGDownloadManager/Classes/DGDownloadManagers/**/*'
    #ss.dependency "AFNetworking", "~> 3.1.0"
  #end
  
  # s.resource_bundles = {
  #   'DGDownloadManager' => ['DGDownloadManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency "AFNetworking", "~> 3.1.0"
end
