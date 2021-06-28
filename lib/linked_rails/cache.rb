# frozen_string_literal: true

module LinkedRails
  class Cache
    extend RDF::Serializers::HextupleSerializer

    class << self
      def invalidate(iri)
        write([invalidate_resource(iri)])
      end

      def invalidate_all
        invalidate(Vocab.sp.Variable)
      end

      def write(delta)
        Redis.new.publish(
          ENV['CACHE_CHANNEL'],
          delta.map { |s| Oj.fast_generate(value_to_hex(*s)) }.join("\n")
        )
      end

      private

      def invalidate_resource(iri)
        [
          Vocab.sp.Variable,
          Vocab.sp.Variable,
          Vocab.sp.Variable,
          LinkedRails::Vocab.ontola["invalidate?graph=#{CGI.escape(iri)}"]
        ]
      end
    end
  end
end
