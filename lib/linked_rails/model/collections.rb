# frozen_string_literal: true

module LinkedRails
  module Model
    module Collections
      extend ActiveSupport::Concern

      COLLECTION_CUSTOMIZABLE_OPTIONS = {
        # display [Sym] The default display type.
        #   Choose between :grid, :settingsTable, :table, :card, :default
        display: :default,
        # grid_max_columns [Integer] The default amount of columns to use in a grid.
        grid_max_columns: 3,
        # page_size [Integer] The default page size.
        page_size: 20,
        # table_type [Sym] The columns to use in the table.
        table_type: lambda {
          case display&.to_sym
          when :table
            :default
          when :settingsTable
            :settings
          end
        },
        # title String The default title.
        title: -> { title_from_translation },
        # type [Sym] The default pagination type.
        #   Choose between :paginated, :infinite.
        type: :paginated
      }.freeze
      COLLECTION_STATIC_OPTIONS = {
        # association [Sym] The association of the collection items.
        association: nil,
        # association_base [Scope, Array] The items of the collection.
        association_base: -> { apply_scope(sorted_association(filtered_association)) },
        # association_class [Class] The class of the collection items.
        association_class: nil,
        # association_scope [Sym] The scope applied to the collection.
        association_scope: nil,
        # collection_class [Class] The base class of the collection.
        #   If you want to use a class other than LinkedRails.collection_class.
        collection_class: nil,
        # collection_class [Hash] The default filters applied to the collection.
        default_filters: {},
        # collection_class [Array<Hash>] The default sortings applied to the collection.
        default_sortings: [{key: Vocab.schema.dateCreated, direction: :desc}],
        # iri_template_keys [Array<Sym>] Custom query keys for the iri template
        iri_template_keys: [],
        # joins [Array<Sym>, Sym] The associations to join
        joins: nil,
        # parent [Instance] The default parent of a collection.
        parent: nil,
        # parent_iri [Array<String>] The iri elements of the parent
        parent_iri: -> { parent&.iri_elements },
        # part_of [Instance] The record to serialize as isPartOf
        part_of: -> { parent },
        # policy_scope [Scope] The policy scope class to be used for scoping
        #   Set to false to skip scoping
        policy_scope: -> { policy ? policy::Scope : Pundit::PolicyFinder.new(filtered_association).scope! },
        # route_key [Symbol, String] The route key for the association
        route_key: nil
      }.freeze
      COLLECTION_OPTIONS = COLLECTION_CUSTOMIZABLE_OPTIONS.merge(COLLECTION_STATIC_OPTIONS)

      module ClassMethods
        def collection_iri(**opts)
          LinkedRails.iri(path: collection_root_relative_iri(**opts))
        end

        # Sets the defaults for all collections for this class.
        # Can be overridden by #with_collection, called from associated models,
        # or by passing parameters in an iri.
        # @param [Hash] options
        def collection_options(**options)
          initialize_default_collection_opts

          options.each do |key, value|
            raise("Invalid key passed to collection_options: #{key}") unless valid_collection_option?(key)

            _default_collection_opts[key] = value
          end
          _default_collection_opts[:iri_template] = LinkedRails.collection_class.generate_iri_template(
            _default_collection_opts[:iri_template_keys]
          )
          _default_collection_opts
        end

        def collection_root_relative_iri(**opts)
          opts[:filter] = LinkedRails.collection_class.filter_iri_opts(opts[:filter]) if opts.key?(:filter)
          opts[:route_key] = collection_route_key
          default_collection_option(:iri_template).expand(**opts)
        end

        def collection_route_key
          default_collection_option(:route_key) || route_key
        end

        def default_collection_options
          initialize_default_collection_opts

          _default_collection_opts
        end

        def default_collection_option(key)
          default_collection_options[key]
        end

        # Defines a collection to be used in {collection_for}
        # @see Ldable#collection_for
        # @note Adds a instance_method <name>_collection
        # @param [Hash] name as to be used in {collection_for}
        # @param [Hash] options See COLLECTION_OPTIONS
        # @return [Collection]
        def with_collection(name, **options) # rubocop:disable Metrics/AbcSize
          options[:association] ||= name.to_sym
          options[:association_class] ||= name.to_s.classify.constantize
          merged_options = options[:association_class].default_collection_options.merge(options)
          merged_options[:iri_template] = LinkedRails.collection_class.generate_iri_template(
            merged_options[:iri_template_keys]
          )
          collections_add(name: name, options: merged_options)

          define_method "#{name.to_s.singularize}_collection" do |opts = {}|
            collection_for(name, **opts)
          end
        end

        private

        def collections_add(opts)
          initialize_collections
          collections.delete_if { |c| c[:name] == opts[:name] }
          opts[:options] = sanitized_collection_options(opts[:options])
          collections.append(opts)
        end

        def initialize_collections
          return if collections && method(:collections).owner == singleton_class

          self.collections = superclass.try(:collections)&.dup || []
        end

        def initialize_default_collection_opts # rubocop:disable Metrics/AbcSize
          return if _default_collection_opts && method(:_default_collection_opts).owner == singleton_class

          self._default_collection_opts = (superclass.try(:_default_collection_opts) || COLLECTION_OPTIONS).dup

          _default_collection_opts[:collection_class] ||= LinkedRails.collection_class
          _default_collection_opts[:association_class] = self
          _default_collection_opts[:iri_template] = LinkedRails.collection_class.generate_iri_template(
            _default_collection_opts[:iri_template_keys]
          )

          _default_collection_opts
        end

        def sanitized_collection_options(opts)
          opts.each_with_object(HashWithIndifferentAccess.new) do |(key, value), hash|
            raise("Invalid key passed to with_collection: #{key}") unless valid_collection_option?(key.to_sym)

            hash_key = COLLECTION_CUSTOMIZABLE_OPTIONS.key?(key.to_sym) ? "default_#{key}" : key

            hash[hash_key] = value
          end
        end

        def valid_collection_option?(key)
          COLLECTION_OPTIONS.key?(key) || key == :iri_template
        end
      end

      included do
        class_attribute :collections
        class_attribute :_default_collection_opts,
                        instance_accessor: false,
                        instance_predicate: false
      end

      # Initialises a {Collection} for one of the collections defined by {has_collection}
      # @see Ldable#has_collection
      # @param [Hash] name as defined with {has_collection}
      # @param [Class] user_context
      # @param [Hash] filter
      # @param [Integer, String] page
      # @param [ApplicationRecord] part_of
      # @param [Hash] opts Additional options to be passed to the collection.
      # @return [Collection]
      def collection_for(name, **instance_opts)
        collection_opts = collection_options_for(name).dup
        return if collection_opts.blank?

        collection_opts[:name] = name
        collection_opts[:parent] = self
        collection_class =
          collection_opts.delete(:collection_class) ||
          collection_opts[:association_class].default_collection_option(:collection_class) ||
          LinkedRails.collection_class
        collection_class.collection_or_view(collection_opts, instance_opts)
      end

      def collection_iri(collection, **opts)
        LinkedRails.iri(path: collection_root_relative_iri(collection, **opts))
      end

      def collection_options_for(name)
        opts = collections.detect { |c| c[:name] == name.to_sym }
        raise("Collection #{name} not found for #{self}") unless opts

        opts[:options] || {}
      end

      def collection_root_relative_iri(collection, **opts)
        collection_opts = collection_options_for(collection).dup
        template = collection_opts[:iri_template]
        klass = collection_opts[:association_class]
        opts[:route_key] = collection_opts[:route_key] || klass.collection_route_key
        opts[:parent_iri] = iri_elements

        template.expand(**opts).to_s
      end

      def parent_collections(user_context)
        return [self.class.root_collection(user_context: user_context)] if try(:parent).try(:collections).blank?

        parent_collections_for(parent, user_context)
      end

      private

      def parent_collections_for(parent, user_context)
        parent
          .collections
          .select { |collection| is_a?(collection[:options][:association_class]) }
          .map { |collection| parent.collection_for(collection[:name], user_context: user_context) }
      end
    end
  end
end
