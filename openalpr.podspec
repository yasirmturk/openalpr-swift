Pod::Spec.new do |spec|
  spec.name = "openalpr"
  spec.version = "1.0.0"
  spec.summary = "iOS Framework for the openalpr library ready to use in Swift and Objective-C."
  spec.homepage = "https://www.yasirmturk.com/"
  spec.license = { type: 'MIT', file: 'LICENSE' }
  spec.authors = { "Yasir M Türk" => 'i@yasirmturk.com' }
  spec.social_media_url = "https://twitter.com/yasirmturk"

  spec.platform = :ios, "9.1"
  spec.requires_arc = true
  spec.source = { git: "git remote add origin https://github.com/yasirmturk/openalpr-swift.git", tag: "v#{spec.version}", submodules: true }
  spec.source_files = "openalpr-swift/**/*.{h,mm,swift}"
end