Gem::Specification.new do |spec|
  spec.name          = "lita-reddit"
  spec.version       = "0.0.5"
  spec.authors       = ["Chris Baker"]
  spec.email         = ["dosman711@gmail.com"]
  spec.description   = %q{A Reddit handler for Lita.}
  spec.summary       = %q{A Reddit handler for the lita chat robot.}
  spec.homepage      = "https://github.com/dosman711/lita-reddit"
  spec.license       = "MIT"
  spec.metadata      = { "lita_plugin_type" => "handler" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "lita", ">= 4.2"
  spec.add_runtime_dependency "redd"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency "rspec", ">= 3.0.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "coveralls"
end
