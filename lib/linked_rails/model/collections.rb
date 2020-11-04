# frozen_string_literal: true

module LinkedRails
  module Model
    module Collections
      extend ActiveSupport::Concern

      included do
        class_attribute :collections
        class_attribute :inc_nested_collection
        self.inc_nested_collection = [
          default_view: {member_sequence: :members},
          filter_fields: :options,
          filters: [],
          sortings: []
        ].freeze
        class_attribute :inc_shallow_collection
        self.inc_shallow_collection = [
          filter_fields: :options,
          filters: [],
          sortings: []
        ].freeze
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
      def collection_for(name, opts = {})
        collection_opts = collections.detect { |c| c[:name] == name }.try(:[], :options)
        return if collection_opts.blank?

        cached_collection(name, opts) ||
          cache_collection(name, opts, collection_opts)
      end

      def parent_collections(user_context)
        return [] if try(:parent).try(:collections).blank?

        parent_collections_for(parent, user_context)
      end

      private

      def cache_collection(name, instance_opts, collection_opts)
        opts = instance_opts.merge(**collection_opts).with_indifferent_access
        opts[:name] = name
        opts[:parent] = self
        opts[:part_of] = opts.key?(:part_of) ? send(opts[:part_of]) : self
        collection = LinkedRails.collection_class.new(opts)

        @collection_instances[collection_cache_key(name, opts)] = collection

        collection
      end

      def cached_collection(name, opts)
        @collection_instances ||= {}
        @collection_instances[collection_cache_key(name, opts)]
      end

      def collection_cache_key(name, opts)
        key = opts.dup
        key[:name] = name
        key[:user_context] = key.key?(:user_context)
        key.hash
      end

      def parent_collections_for(parent, user_context)
        parent
          .collections
          .select { |collection| is_a?(collection[:options][:association_class]) }
          .map { |collection| parent.collection_for(collection[:name], user_context: user_context) }
      end

      module ClassMethods
        def collections_add(opts)
          initialize_collections
          collections.delete_if { |c| c[:name] == opts[:name] }
          collections.append(opts)
        end

        def initialize_collections
          return if collections && method(:collections).owner == singleton_class

          self.collections = superclass.try(:collections)&.dup || []
        end

        # Defines a collection to be used in {collection_for}
        # @see Ldable#collection_for
        # @note Adds a instance_method <name>_collection
        # @param [Hash] name as to be used in {collection_for}
        # @param [Hash] options
        # @option options [Sym] association the name of the association
        # @option options [Class] association_class the class of the association
        # @option options [Sym] joins the associations to join
        # @return [Collection]
        def with_collection(name, options = {})
          options[:association] ||= name.to_sym
          options[:association_class] ||= name.to_s.classify.constantize

          collections_add(name: name, options: options)

          define_method "#{name.to_s.singularize}_collection" do |opts = {}|
            collection_for(name, opts)
          end
        end
      end
    end
  end
end
