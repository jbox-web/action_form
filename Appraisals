# frozen_string_literal: true

RAILS_VERSIONS = %w[
  5.0.7
  5.1.6
  5.2.2
  6.0.0.beta2
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
  end
end
