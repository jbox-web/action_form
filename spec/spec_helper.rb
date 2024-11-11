# frozen_string_literal: true

require 'simplecov'

# Start SimpleCov
SimpleCov.start do
  add_filter 'spec/'
end

# Load Rails dummy app
ENV['RAILS_ENV'] = 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

# Load test gems
require 'rspec/rails'
require 'capybara/cuprite'

# Load our own config
require_relative 'config_rspec'
require_relative 'config_capybara'

# Load test helpers
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
