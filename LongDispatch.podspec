Pod::Spec.new do |spec|
  spec.name         = 'LongDispatch'
  spec.version      = '1.0.1'
  spec.license      = 'MIT'
  spec.summary      = 'An Objective-C tool for Dispatch'
  spec.homepage     = 'https://github.com/lizilong1989/LongDispatch.git'
  spec.author       = {'zilong.li' => 'xuehongmeicarrie@aliyun.com'}
  spec.source       =  {:git => 'https://github.com/lizilong1989/LongDispatch.git', :tag => spec.version.to_s }
  spec.source_files = "LongDispatch/**/*.{h,m,mm,cpp,hpp}"
  spec.public_header_files = 'LongDispatch/**/*.{h}'
  spec.platform     = :ios, '6.0'
  spec.requires_arc = true
  spec.xcconfig     = {'OTHER_LDFLAGS' => '-ObjC'}
end
