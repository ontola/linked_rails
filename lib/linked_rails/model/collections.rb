# frozen_string_literal: true

module LinkedRails
  module Model
    module Collections
      extend ActiveSupport::Concern

      included do
        class_attribute :collections
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
      def collection_for(name, instance_opts = {})
        collection_opts = collections.detect { |c| c[:name] == name }.try(:[], :options).dup
        return if collection_opts.blank?

        collection_opts[:name] = name
        collection_opts[:parent] = self
        collection_opts[:part_of] = collection_opts.key?(:part_of) ? send(collection_opts[:part_of]) : self
        collection_class = collection_opts.delete(:collection_class) || LinkedRails.collection_class
        collection_class.collection_or_view(collection_opts, instance_opts)
      end

      def parent_collections(user_context)
        return [] if try(:parent).try(:collections).blank?

        parent_collections_for(parent, user_context)
      end

      private

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
