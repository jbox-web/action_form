# frozen_string_literal: true

require 'zeitwerk'
loader = Zeitwerk::Loader.for_gem
loader.setup

module ActionForm
  require 'action_form/engine' if defined?(Rails)

  def self.rails_buggy?
    Rails.gem_version >= Gem::Version.new('7.0.3')
  end

  def self.rails_error_object?
    Rails.gem_version >= ::Gem::Version.new('6.1.0.alpha')
  end
end
