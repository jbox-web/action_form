# frozen_string_literal: true

RAILS_VERSIONS = %w[
  6.1.7
  7.0.8
  7.1.3
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
  end
end
