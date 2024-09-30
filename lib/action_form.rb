# frozen_string_literal: true

# require external dependencies
require 'zeitwerk'

# load zeitwerk
Zeitwerk::Loader.for_gem.tap do |loader| # rubocop:disable Style/SymbolProc
  loader.setup
end

module ActionForm
  require_relative 'action_form/engine'

  def self.rails_buggy?
    Rails.gem_version >= Gem::Version.new('7.0.3')
  end
end
