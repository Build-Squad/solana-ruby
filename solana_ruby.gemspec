# frozen_string_literal: true

require_relative "lib/solana_ruby/version"

Gem::Specification.new do |spec|
  spec.name          = "solana_ruby"
  spec.version       = SolanaRuby::VERSION
  spec.authors       = ["Navtech Team"]
  spec.email         = ["gmudumuntala@navaratan.com"]
  spec.licenses      = ['MIT']
  spec.summary       = "Solana Ruby SDK"
  spec.description   = "This gem allows to use JSON RPC API Methods from solana."
  spec.homepage      = "https://github.com/navtech-io/solana-ruby"
  spec.required_ruby_version = ">= 3.0.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"

  # spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'websocket-client-simple', '~> 0.8.0'
  spec.add_dependency 'brakeman', '~> 6.1.2'
  spec.add_dependency 'rubycritic', '~> 4.9.0'
  spec.add_dependency 'simplecov', '~> 0.22.0'
  spec.add_dependency 'pry', '~> 0.14.2'
end
