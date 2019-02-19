# frozen_string_literal: true

require 'zeitwerk'
Zeitwerk::Loader.for_gem.setup

module ActionForm
  require 'action_form/engine' if defined?(Rails)
end
