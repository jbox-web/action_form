# frozen_string_literal: true

RAILS_VERSIONS = %w[
  5.1.7
  5.2.4
  6.0.3
].freeze

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'sqlite3', '~> 1.3.0' unless version == '6.0.3'
  end
end
