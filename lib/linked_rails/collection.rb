# frozen_string_literal: true

require 'pundit'

require_relative 'collection/filter'
require_relative 'collection/filterable'
require_relative 'collection/iri'
require_relative 'collection/sortable'
require_relative 'collection/sorting'
require_relative 'collection/view'
require_relative 'collection/paginated_view'
require_relative 'collection/infinite_view'

module LinkedRails
  class Collection
    include ActiveModel::Serialization
    include ActiveModel::Model
    include LinkedRails::Model::Enhancements
    include LinkedRails::Model::Iri
    include LinkedRails::Collection::Filterable
    include LinkedRails::Collection::Iri
    include LinkedRails::Collection::Sortable

    enhance LinkedRails::Enhancements::Actionable

    attr_accessor :association, :association_class, :association_scope, :display, :include_map, :joins, :name,
                  :parent, :part_of, :user_context, :page_size
    attr_writer :association_base, :default_type, :title, :type, :views

    # prevents a `stack level too deep`
    def as_json(options = {})
      super(options.merge(except: %w[association_class]))
    end

    def association_base
      @association_base ||= apply_scope(filtered_association)
    end

    def default_page_size
      association_class.try(:default_per_page)
    end

    def default_view
      @default_view ||= view_with_opts(default_view_opts)
    end

    def new_child(options)
      attrs = options.merge(new_child_values)
      self.class.new(attrs)
    end

    def title
      return @title.call(parent) if @title.respond_to?(:call)

      @title || title_from_translation
    end

    def title_from_translation
      plural = association_class.name.tableize
      I18n.t("#{plural}.collection.#{filter&.values&.join('.').presence || name}",
             count: ->(_opts) { total_count },
             default: I18n.t("#{plural}.plural",
                             default: plural.humanize))
    end

    def total_count
      @total_count ||= association_base.try(:total_count) || association_base.count
    end

    def type
      @type&.to_sym || default_type
    end

    def views
      @views || [default_view]
    end

    def view_with_opts(opts)
      LinkedRails.view_class.new({collection: self, type: type, page_size: page_size}.merge(opts))
    end

    private

    def action_list
      association_class.try(:action_list).new(resource: self)
    end

    def apply_scope(association)
      policy_scope = Pundit::PolicyFinder.new(association_class).scope
      policy_scope ? policy_scope.new(user_context, association).resolve : association
    end

    def default_type
      @default_type || :paginated
    end

    def default_view_opts
      opts = {
        include_map: (include_map || {}),
        type: type,
        page_size: page_size || default_page_size,
        filter: filter
      }
      opts[:page] = 1 if type == :paginated
      opts[:before] = Time.current.utc.to_s(:db) if type == :infinite
      opts
    end

    def new_child_values
      instance_values
        .slice('association', 'association_class', 'association_scope', 'parent', 'default_filters')
        .merge(
          unfiltered_collection: filtered? ? @unfiltered_collection : self,
          user_context: user_context
        )
    end
  end
end
