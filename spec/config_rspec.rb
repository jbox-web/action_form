RSpec.configure do |config|
  config.include Capybara::DSL

  # Use DB agnostic schema by default
  load Rails.root.join('db', 'schema.rb').to_s

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # disable monkey patching
  # see: https://relishapp.com/rspec/rspec-core/v/3-8/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  # set fixtures path
  config.fixture_path = File.expand_path('fixtures', __dir__)

  # include ActionView::TestCase::Behavior so we can access to @output_buffer in views tests
  config.include ActionView::TestCase::Behavior, file_path: %r{spec/views}
end
