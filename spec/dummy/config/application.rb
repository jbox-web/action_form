# frozen_string_literal: true

# Load Bundler
require_relative 'boot'

# Load Rails
require 'rails/all'

# Require the gems listed in Gemfile
Bundler.require(*Rails.groups)

# Load tested lib
require 'jquery-rails'

module Dummy
  class Application < Rails::Application
    config.autoload_paths << Rails.root.join('lib')
  end
end
