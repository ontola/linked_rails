# frozen_string_literal: true

require 'uri_template'

module LinkedRails
  class URITemplate < URITemplate::RFC6570
    ARRAY_SUFFIX = '%5B%5D'

    private

    def normalize_variables(vars)
      variables
        .select { |var| var.ends_with?(ARRAY_SUFFIX) }
        .each_with_object(super.with_indifferent_access) do |var, hash|
        key = var.sub(ARRAY_SUFFIX, '')
        hash[var] = normalize_array_value(hash[key]) if hash.key?(key)
      end
    end

    def normalize_array_value(original_value)
      return original_value unless original_value.is_a?(Hash)

      original_value.map do |key, values|
        (values.is_a?(Array) ? values : [values]).map do |value|
          "#{CGI.escape(key.to_s)}=#{value}"
        end
      end.flatten
    end
  end
end
