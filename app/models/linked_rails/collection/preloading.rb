# frozen_string_literal: true

module LinkedRails
  class Collection
    module Preloading
      attr_accessor :preloaded
      attr_writer :members

      private

      def collection_opts(key, option)
        options = association_class.collections.find { |opts| opts[:name].to_s == key[0...-11].pluralize }
        options[:options][option] if options
      end

      def inverse_of_preloaded(child, opts)
        raw_members.find { |member| member.id == child.send(opts[:foreign_key]) }
      end

      def preload_association(key, includes)
        preload = preload_keys(association_class, key, includes)
        ActiveRecord::Associations::Preloader.new.preload(raw_members, key => preload) if preload.present?
      end

      def preload_keys(klass, key, includes)
        reflection = reflection_for(klass, key)
        return nil if reflection.nil?

        Hash[
          (reflection.klass.reflect_on_all_associations.map(&:name) & includes.keys).map do |child|
            [child, preload_keys(reflection.klass, child, includes[child])]
          end
        ]
      end

      def preload_collection(key, reflection)
        return if reflection.nil?

        opts = preload_opts(reflection)
        preloaded = preload_collection_members(opts)
        raw_members.each do |member|
          member.send(key, user_context: user_context).default_view.members = preloaded[member.id] || opts[:klass].none
        end
      end

      def preload_collection_members(opts)
        opts[:klass]
          .select('*')
          .from(ranked_query(opts))
          .where('child_rank <= ?', opts[:count])
          .includes(opts[:klass].includes_for_serializer)
          .each { |child| preloaded_inverse_of(child, opts) }
          .group_by(&opts[:foreign_key])
      end

      def preload_included_association(key, value)
        if key.to_s.ends_with?('_collection')
          if value[:default_view]&.key?(:member_sequence)
            association_name = collection_opts(key, :association)
            preload_collection(key, reflection_for(association_class, association_name)) if association_name
          end
        else
          preload_association(key, value)
        end
      end

      def preload_included_associations
        include_map&.each(&method(:preload_included_association))
        self.preloaded = true
      end

      def preload_included_associations?
        !preloaded && association_class < ActiveRecord::Base
      end

      def preloaded_inverse_of(child, opts)
        inverse = inverse_of_preloaded(child, opts)
        child.send("#{opts[:inverse_of]}=", inverse) if inverse
      end

      def ranked_query(opts)
        subquery =
          apply_scope(opts[:klass].where(opts[:foreign_key] => raw_members.map(&opts[:primary_key])))
            .select(ranked_query_sql(opts))
            .to_sql
        Arel.sql("(#{subquery}) AS #{opts[:table_name]}")
      end

      def ranked_query_sorting(opts)
        opts[:klass]
          .order(
            LinkedRails
              .collection_sorting_class
              .from_array(opts[:klass], opts[:klass].default_sortings)
              .map(&:sort_value)
          ).order_values
      end

      def ranked_query_sql(opts)
        table_name = opts[:table_name]
        sort = ranked_query_sorting(opts)
        table = Arel::Table.new(table_name)
        partition = Arel::Nodes::Window.new.partition(table[opts[:foreign_key]]).order(sort).to_sql
        "#{table_name}.*, dense_rank() OVER #{partition} AS child_rank"
      end

      def reflection_for(klass, key)
        klass.reflect_on_association(key)
      end

      def preload_opts(reflection)
        {
          count: reflection.klass.default_per_page,
          foreign_key: reflection.foreign_key.to_sym,
          inverse_of: reflection.inverse_of.name.to_sym,
          klass: reflection.klass,
          primary_key: reflection.active_record_primary_key.to_sym,
          table_name: reflection.table_name.to_sym
        }
      end
    end
  end
end
