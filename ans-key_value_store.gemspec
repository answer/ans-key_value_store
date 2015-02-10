# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ans/key_value_store/version'

Gem::Specification.new do |spec|
  spec.name          = "ans-key_value_store"
  spec.version       = Ans::KeyValueStore::VERSION
  spec.authors       = ["sakai shunsuke"]
  spec.email         = ["sakai@ans-web.co.jp"]
  spec.summary       = %q{key value テーブルと ActiveModel のアダプタ}
  spec.description   = %q{key value なリレーション DB のテーブルから値を読み出したり書き込んだりする ActiveModel なインターフェイスを提供する}
  spec.homepage      = "https://github.com/answer/ans-key_value_store"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
