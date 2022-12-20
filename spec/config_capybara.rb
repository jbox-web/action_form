Capybara.register_driver(:headless_chrome) do |app|
  Capybara::Cuprite::Driver.new(app, headless: true, js_errors: true, window_size: [1200, 800])
end

Capybara.current_driver    = :headless_chrome
Capybara.javascript_driver = :headless_chrome

Capybara.run_server = true
Capybara.server     = :puma, { Silent: true }
