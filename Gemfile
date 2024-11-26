# frozen_string_literal: true

source 'https://rubygems.org'

# Specify your gem's dependencies in dragnet.gemspec
gemspec

gem 'pry', '~>0'
gem 'rake', '~> 12.0'
gem 'rspec', '~> 3.0'
gem 'simplecov', '~> 0.17.0'
gem 'yard', '~> 0'

group :linting do
  gem 'reek', '~> 6'
  gem 'rubocop', '~> 1'
  gem 'rubocop-rspec', '~> 3'
end

group :requirements do
  gem 'dim-toolkit', '2.1.1' # Fixed to a minor because the Gem doesn't follow semantic versioning.
end
