# frozen_string_literal: true

require_relative 'lib/dragnet/version'

Gem::Specification.new do |spec|
  spec.name          = 'dragnet'
  spec.version       = Dragnet::VERSION
  spec.authors       = ['ESR Labs GmbH']
  spec.email         = ['info@esrlabs.com']

  spec.summary       = 'A gem to verify, validate and analyse MTR (Manual Test Record) files.'
  spec.description   = 'Provides a command line tool to perform different types of validations '\
                       'on MTR files. These files are YAML files that contain information about '\
                       'the performed test and the revision (commit) for which the test was '\
                       'performed.'
  spec.homepage      = 'https://github.com/esrlabs/dragnet'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7.0')

  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = 'https://github.com/esrlabs/dragnet/blob/master/CHANGELOG.md'

  spec.add_runtime_dependency 'activesupport', '~> 7'
  spec.add_runtime_dependency 'colorize', '~> 0.8'
  spec.add_runtime_dependency 'git', '~> 1.8'
  spec.add_runtime_dependency 'thor', '~> 1.1'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(documentation|req|spec)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
