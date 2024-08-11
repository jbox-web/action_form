# frozen_string_literal: true

RAILS_VERSIONS = %w[
  7.0.8
  7.1.3
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version

    case version
    when "7.0.8"
      gem "sprockets-rails"

      # Fix: LoadError: cannot load such file -- base64
      install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.3.0") }' do
        gem "base64"
        gem "bigdecimal"
        gem "mutex_m"
        gem "drb"
        gem "logger"
      end

    when "7.1.3"
      gem "sprockets-rails"

      # Fix: warning: logger was loaded from the standard library, but will no longer be part of the default gems since Ruby 3.5.0. Add logger to your Gemfile or gemspec.
      install_if '-> { Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.4.0") }' do
        gem "logger"
      end
    end

  end
end
