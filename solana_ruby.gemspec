# frozen_string_literal: true
require_relative "lib/solana_ruby/version"

Gem::Specification.new do |spec|
  spec.name          = "solana-ruby-web3js"
  spec.version       = SolanaRuby::VERSION
  spec.authors       = ["BuildSquad"]
  spec.email         = ["engineering@buildsquad.net"]
  spec.licenses      = ['MIT']
  spec.summary       = "Solana Ruby SDK"
  spec.description   = "This gem allows to use JSON RPC API Methods from solana."
  spec.homepage      = "https://github.com/Build-Squad/solana-ruby"
  spec.metadata = {
    "homepage_uri"        => "https://github.com/Build-Squad/solana-ruby",
    "source_code_uri"     => "https://github.com/Build-Squad/solana-ruby",
    "documentation_uri"   => 'https://www.rubydoc.info/gems/solana-ruby-web3js'
  }
  spec.required_ruby_version = ">= 3.0.0"
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.files.reject! { |f| f.end_with?('.gem') }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'websocket-client-simple', '~> 0.8.0'
  spec.add_dependency 'base58', '~> 0.2.3'
  spec.add_dependency 'base64', '~> 0.2.0'
  spec.add_dependency 'rbnacl', '~> 6.0'
  spec.add_dependency 'ed25519'
  spec.add_development_dependency 'brakeman', '~> 6.1.2'
  spec.add_development_dependency 'rubycritic', '~> 4.9.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  spec.add_development_dependency 'pry', '~> 0.14.2'
  spec.add_development_dependency 'rubocop', '~> 1.21'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'ed25519'
  spec.add_development_dependency 'yard'
end
