# frozen_string_literal: true

require_relative 'lib/action_form/version'

Gem::Specification.new do |s|
  s.name        = 'action_form'
  s.version     = ActionForm::VERSION::STRING
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Petros Markou', 'Nicolas Rodriguez']
  s.email       = ['markoupetr@gmail.com', 'nico@nicoladmin.fr']
  s.homepage    = 'https://github.com/jbox-web/action_form'
  s.summary     = 'Create nested forms with ease.'
  s.description = 'An alternative layer to accepts_nested_attributes_for by using Form Models.'
  s.license     = 'MIT'
  s.metadata    = {
    'homepage_uri'    => 'https://github.com/jbox-web/action_form',
    'changelog_uri'   => 'https://github.com/jbox-web/action_form/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/jbox-web/action_form',
    'bug_tracker_uri' => 'https://github.com/jbox-web/action_form/issues',
  }

  s.required_ruby_version = '>= 3.2.0'

  s.files = Dir['README.md', 'CHANGELOG.md', 'LICENSE', 'lib/**/*.rb', 'app/**/*.js']

  s.add_dependency 'rails', '>= 7.0'
  s.add_dependency 'zeitwerk'
end
