#
#  Be sure to run `pod spec lint SULoader.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "DGDownloadManager"
  s.version      = "0.0.1"
  s.summary      = "A short description of DGDownloadManager"
  s.homepage     = "https://github.com/liudiange/DGDownloadManager"
  s.license      = "MIT"
  s.author             = { "diange Liu" => "shaoyeliudiange@163.com" }
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/liudiange/DGDownloadManager.git", :tag => "0.0.1" }
  s.source_files  = "DGDownloadManager/DGDownloadManagers/*"
  s.framework  = "UIKit"
  s.dependency "AFNetworking", "~> 3.1.0"
  
  end
