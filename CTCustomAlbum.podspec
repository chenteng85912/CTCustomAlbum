
Pod::Spec.new do |s|

  s.name         = "CTCustomAlbum"
  s.version      = "1.0.0"
  s.summary      = "CustomAlbum make with Photos.kit."
  s.homepage     = "https://github.com/chenteng85912/CTCustomAlbum"
  s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.authors      = { "陈腾" => "chenteng85912@163.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/chenteng85912/CTCustomAlbum.git", :tag => s.version}
  s.requires_arc = true

  s.source_files  = "CTCustomAlbum/**/CTCustomAlbumConfig.h"
  s.frameworks = "Photos", "AVFoundation"

#自定义相册
    s.subspec 'CustomAlbum' do |ss|
        ss.source_files = "CTCustomAlbum/**/CustomAlbum/*.{h,m}"
        ss.resources = "CTCustomAlbum/**/CustomAlbum/*.{png,xib}"
    end

#调用系统相机和相册
    s.subspec 'OnePhoto' do |ss|
        ss.source_files = "CTCustomAlbum/**/OnePhoto/*.{h,m}"
    end

end
