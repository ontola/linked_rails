# frozen_string_literal: true

require 'pundit'

require_relative 'collection/configuration'
require_relative 'collection/filter'
require_relative 'collection/filterable'
require_relative 'collection/iri'
require_relative 'collection/iri_mapping'
require_relative 'collection/sortable'
require_relative 'collection/sorting'
require_relative 'collection/view'
require_relative 'collection/paginated'
require_relative 'collection/paginated_view'
require_relative 'collection/infinite'
require_relative 'collection/infinite_view'

module LinkedRails
  class Collection # rubocop:disable Metrics/ClassLength
    include ActiveModel::Model
    include LinkedRails::Model::Actionable
    include LinkedRails::Model::IRI
    include LinkedRails::Collection::Configuration
    include LinkedRails::Collection::Filterable
    include LinkedRails::Collection::IRI
    include LinkedRails::Collection::IRIMapping
    include LinkedRails::Collection::Sortable

    attr_accessor :name, :policy, :user_context, :view
    attr_writer :association_base, :views

    alias id iri

    def initialize(**opts)
      opts = opts.with_indifferent_access

      %i[association_class iri_template].each do |key|
        raise("No #{key} given") if opts[key].blank?
      end
      opts[:route_key] ||= opts[:association_class].collection_route_key

      super
    end

    def action_list(user_context)
      @action_list ||= {}
      @action_list[user_context] ||= association_class.try(:action_list)&.new(
        resource: self,
        user_context: user_context
      )
    end

    def actions(user_context = nil)
      return [] if action_list(user_context).nil?

      super
    end

    def apply_scope(association)
      return association if policy_scope == false

      policy_scope.new(user_context, association).resolve
    end

    # prevents a `stack level too deep`
    def as_json(options = {})
      super(options.merge(except: %w[association_class unfiltered_collection collection]))
    end

    def child_resource
      @child_resource ||= build_child
    end

    def columns
      columns_list = association_class.try(:defined_columns).try(:[], table_type)

      RDF::List[*columns_list] if columns_list.present?
    end

    def default_view
      @default_view ||= view_with_opts(default_view_opts)
    end

    def first
      case type
      when :paginated
        iri_with_root(root_relative_iri(page: 1))
      when :infinite
        iri_with_root(root_relative_iri(before: default_before_value))
      end
    end

    def inspect
      "#<#{association_class}Collection iri:#{iri}>"
    end

    def last
      iri_with_root(root_relative_iri(page: [total_page_count, 1].max)) if type == :paginated && total_page_count
    end

    def new_child(options)
      attrs = options.merge(new_child_values)
      self.class.new(**attrs)
    end

    def preview_includes
      {
        default_view: default_view.preview_includes,
        filter_fields: :options,
        filters: [],
        sortings: []
      }
    end

    def total_count
      @total_count ||= association_base.try(:total_count) || unscoped_association.count
    end

    def total_page_count
      (total_count / page_size.to_f).ceil if total_count
    end

    def unscoped_association
      association_base.respond_to?(:unscope) ? association_base.unscope(:select) : association_base
    end

    def views
      @views || [default_view]
    end

    def view_with_opts(opts)
      @views ||= []
      view = collection_view_class.new(**{collection: self, type: type}.merge(opts))
      @views << view
      view
    end

    private

    def build_child
      child =
        parent&.build_child(association_class, user_context: user_context) ||
        association_class.build_new(parent: parent, user_context: user_context)

      child.assign_attributes(permitted_attributes_from_filters(child))
      child
    end

    def collection_view_class
      LinkedRails.collection_view_class
    end

    def default_view_opts
      opts = {
        type: type,
        filter: filter
      }
      opts[:page] = 1 if type == :paginated
      opts[:before] = default_before_value if type == :infinite
      opts
    end

    def paginated?
      type == :paginated
    end

    def permitted_attributes_from_filters(child)
      return {} if @filter.empty?

      parser = LinkedRails::ParamsParser.new(user_context: user_context, params: {filter: @filter})
      permitted_child_keys = Pundit.policy(user_context, child)&.permitted_attributes || []
      parser.attributes_from_filters(association_class).permit(permitted_child_keys)
    end

    def title_from_translation
      plural = association_class.name.tableize

      I18n.t(
        "#{plural}.collection.#{filter&.values&.join('.').presence || name || :default}",
        count: ->(_opts) { total_count },
        default: association_class.plural_label
      )
    end

    def new_child_values
      instance_values
        .slice('iri_template', *LinkedRails::Model::Collections::COLLECTION_STATIC_OPTIONS.keys.map(&:to_s))
        .merge(
          unfiltered_collection: filtered? ? @unfiltered_collection : self,
          user_context: user_context
        )
    end
  end
end
