require 'simplecov'

# Start SimpleCov
SimpleCov.start do
  add_filter 'test/'
end

# Load Rails dummy app
ENV['RAILS_ENV'] = 'test'
require File.expand_path('dummy/config/environment.rb', __dir__)

# Set DB schema
ActiveRecord::Migration.maintain_test_schema!

# Load test gems
require 'rails/test_help'
require 'rails-controller-testing'
Rails::Controller::Testing.install

Rails.backtrace_cleaner.remove_silencers!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.expand_path('support/**/*.rb', __dir__)].each { |f| require f }

ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
