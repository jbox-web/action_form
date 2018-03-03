# frozen_string_literal: true

RAILS_VERSIONS = %w[
  4.2.10
  5.0.6
  5.1.5
  5.2.0.rc1
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'rails-controller-testing' if version != '4.2.10'
  end
end
