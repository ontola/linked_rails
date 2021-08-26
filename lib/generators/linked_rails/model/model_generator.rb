# frozen_string_literal: true

require 'rails/generators/active_record/model/model_generator'

module LinkedRails
  class ModelGenerator < ActiveRecord::Generators::ModelGenerator
    include Rails::Generators::ResourceHelpers
    source_root File.expand_path('templates', __dir__)

    def create_migration_file # rubocop:disable Metrics/AbcSize
      return unless options[:migration] && options[:parent].nil?

      if options[:indexes] == false
        attributes.each { |a| a.attr_options.delete(:index) if a.reference? && !a.has_index? }
      end
      migration_template 'create_table_migration.rb', File.join(db_migrate_path, "create_#{table_name}.rb")
    end

    def copy_files # rubocop:disable Metrics/AbcSize
      template 'action_list.rb', File.join('app', 'actions', class_path, "#{file_name}_action_list.rb")
      template 'controller.rb', File.join('app', 'controllers', class_path, "#{plural_file_name}_controller.rb")
      template 'form.rb', File.join('app', 'forms', class_path, "#{file_name}_form.rb")
      template 'menu_list.rb', File.join('app', 'menus', class_path, "#{file_name}_menu_list.rb")
      template 'policy.rb', File.join('app', 'policies', class_path, "#{file_name}_policy.rb")
      template 'serializer.rb', File.join('app', 'serializers', class_path, "#{file_name}_serializer.rb")
    end

    def insert_route
      after = after_sorted_match(routes_path, /linked_resource\((\w+\))/)

      opts = after ? {after: after} : {before: 'end'}
      inject_into_file(routes_path, routes_line, opts)
    end

    private

    def after_sorted_match(file, matcher, name = class_name)
      after = nil

      File.open(file).each do |line|
        match = line.match(matcher)
        after = line if match.try(:[], 1).present? && match[1] <= name
      end

      return if after == name

      after
    end

    def routes_line
      "  linked_resource(#{class_name})\n"
    end

    def routes_path
      File.join('config', 'routes.rb')
    end
  end
end
