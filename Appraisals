RAILS_VERSIONS = %w(
  4.2.8
  5.0.3
  5.1.1
)

RAILS_VERSIONS.each do |version|
  appraise "rails_#{version}" do
    gem 'rails', version
    gem 'rails-controller-testing' if version != '4.2.8'
  end
end
