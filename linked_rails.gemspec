# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

# Maintain your gem's version:
require 'linked_rails/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = 'linked_rails'
  spec.version     = LinkedRails::VERSION
  spec.authors     = ['Arthur Dingemans']
  spec.email       = ['arthur@argu.co']
  spec.homepage    = 'https://github.com/ontola/linked_rails'
  spec.summary     = 'LinkedRails helps you create a Linked Data application in a matter of seconds.'
  spec.license     = 'GPL-3.0-or-later'

  spec.files = Dir['{app,config,db,lib}/**/*', 'LICENSE', 'Rakefile', 'README.md']

  spec.add_dependency 'active_response', '~> 0.0.2'
  spec.add_dependency 'kaminari-activerecord'
  spec.add_dependency 'pundit'
  spec.add_dependency 'rdf'
  spec.add_dependency 'rdf-serializers', '~> 0.0.10'
  spec.add_dependency 'rdf-vocab'
  spec.add_dependency 'uri_template'

  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'rspec-rails'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rails'
  spec.add_development_dependency 'sqlite3'
end
