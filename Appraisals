# frozen_string_literal: true

appraise 'rails_7.0.8' do
  gem 'rails', '7.0.8'

  # Fix: LoadError: cannot load such file -- base64
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0") }' do
    gem 'base64'
    gem 'bigdecimal'
    gem 'mutex_m'
    gem 'drb'
    gem 'logger'
  end
end

appraise 'rails_7.1.3' do
  gem 'rails', '7.1.3'

  # Fix:
  # warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0.
  # Add logger to your Gemfile or gemspec.
  install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0") }' do
    gem 'logger'
  end
end

appraise 'rails_7.2.0' do
  gem 'rails', '7.2.0'
end
