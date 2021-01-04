if Rails::VERSION::MAJOR == 5 && Rails::VERSION::MINOR == 2
  Rails.application.config.active_record.sqlite3.represent_boolean_as_integer = true
end
