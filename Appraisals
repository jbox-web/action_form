# frozen_string_literal: true

RAILS_VERSIONS = %w[
  5.0.7
  5.1.7
  5.2.4
  6.0.1
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'sqlite3', '~> 1.4.0' if version == '6.0.1'
  end
end
