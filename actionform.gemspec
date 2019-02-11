# frozen_string_literal: true

require_relative 'lib/action_form/version'

Gem::Specification.new do |s|
  s.name        = 'actionform'
  s.version     = ActionForm::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Petros Markou']
  s.email       = ['markoupetr@gmail.com']
  s.homepage    = 'https://github.com/jbox-web/actionform'
  s.summary     = 'Create nested forms with ease.'
  s.description = 'An alternative layer to accepts_nested_attributes_for by using Form Models.'
  s.license     = 'MIT'

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency 'rails', '>= 5.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3', '~> 1.3.0'
end
