Pod::Spec.new do |spec|
  spec.name         = "jstPlayerSDK"
  spec.version      = "1.0.0"
  spec.summary      = "A short description of jstplayersdk."
  spec.description  = <<-DESC
  A short description of jstplayersdk.
                   DESC

  spec.homepage     = "https://www.stream.co.jp/"
  spec.license      = {
       :type => 'PROPRIETARY',
       :text => <<-LICENSE
  Proprietary licensed by
      Apple Inc.
      J-Stream Inc.
                  LICENSE
    }
  spec.author             = { "jst-ishita" => "kosuke.ishita@stream.co.jp" }
  spec.platform     = :ios, "10.0"
  #spec.source       = { :git => "http://EXAMPLE/jstplayersdk.git", :tag => "#{spec.version}" }
  spec.source       = { :path => './' }
  spec.requires_arc = true
  spec.source_files = 'Classes','Classes/**/*.{swift}'
end
