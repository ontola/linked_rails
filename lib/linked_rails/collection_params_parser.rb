# frozen_string_literal: true

module LinkedRails
  class CollectionParamsParser
    attr_reader :params, :user_context

    def initialize(params)
      @user_context = params[:user_context]
      @params = params.is_a?(Hash) ? ActionController::Parameters.new(params) : params
    end

    def collection_params
      return @collection_params if instance_variable_defined?(:@collection_params)

      values = permit_params(:collected_at, :display, :page_size, :table_type, :title, :type)

      filter = filter_params
      values[:filter] = filter if filter

      sort = sorting_params
      values[:sort] = sort if sort

      values[:user_context] = user_context if user_context

      @collection_params = values
    end

    def collection_view_params
      return @collection_view_params if instance_variable_defined?(:@collection_view_params)

      values = permit_params(:page)

      before = before_params
      values[:before] = before if before

      @collection_view_params = values
    end

    def filter_params # rubocop:disable Metrics/AbcSize
      return @filter_params if instance_variable_defined?(:@filter_params)

      values = permit_params(filter: [])[:filter] || permit_params(filter: {})[:filter]
      return @filter_params = values if values.is_a?(Hash)
      return @filter_params = {} if values.blank?

      @filter_params = values.each_with_object({}) do |f, hash|
        values = f.split('=')
        key = RDF::URI(CGI.unescape(values.first))
        hash[key] ||= []
        hash[key] << CGI.unescape(values.second)
      end
    end

    private

    def before_params
      return @before_params if instance_variable_defined?(:@before_params)

      values = permit_params(before: [])[:before]
      return @before_params = nil if values.blank?

      @before_params = values.map do |f|
        key, value = f.split('=')
        {key: RDF::URI(CGI.unescape(key)), value: value}
      end
    end

    def parse_filter_value(value)
      return value if value.is_a?(Hash)

      key, value = value.split('=')
      {key: RDF::URI(CGI.unescape(key)), direction: value}
    end

    def permit_params(*keys)
      params
        .permit(*keys)
        .to_h
        .with_indifferent_access
    end

    def sorting_params
      return @sorting_params if instance_variable_defined?(:@sorting_params)

      values = permit_params(sort: [])[:sort]
      return @sorting_params = nil if values.blank?

      @sorting_params = values.map do |f|
        parse_filter_value(f)
      end
    end
  end
end
