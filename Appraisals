# frozen_string_literal: true

RAILS_VERSIONS = %w[
  4.2.11
  5.0.7
  5.1.6
  5.2.2
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'rails-controller-testing' if version != '4.2.10'
  end
end
