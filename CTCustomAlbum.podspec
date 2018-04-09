
Pod::Spec.new do |s|
    s.name         = 'CTCustomAlbum'
    s.version      = '1.0.0'
    s.summary      = 'CustomAlbum with Photo.kit'
    s.homepage     = 'https://github.com/chenteng85912/CTCustomAlbum'
    s.license       = { :type => "MIT", :file => "LICENSE" }
    s.authors      = {'CHENTENG' => 'chenteng85912@163.com'}
    s.platform     = :ios, '8.0'
    s.source       = {:git => 'https://github.com/chenteng85912/CTCustomAlbum.git', :tag => s.version}
    s.requires_arc = true

    s.source_files = 'CTCustomAlbum/**/*.{h,m}'
    s.frameworks = 'Photos', 'AVFoundation'

#自定义相册
    s.subspec 'CTCustomAlbum' do |ss|
        ss.source_files = 'CTCustomAlbum/**/CustomAlbum/*.{h,m}'
        ss.resources = "CTCustomAlbum/**/CTCustomAlbum/*.{png,xib}"
    end

#调用系统相机和相册
    s.subspec 'CTOnePhoto' do |ss|
        ss.source_files = 'CTCustomAlbum/**/CTOnePhoto/*.{h,m}'
    end

end
