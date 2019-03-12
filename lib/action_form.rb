# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module ActionForm
  require 'action_form/engine' if defined?(Rails)
end
