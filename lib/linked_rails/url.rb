module LinkedRails
  class URL
    class << self
      def as_href(url)
        uri = URI(url)
        uri.path = uri.path.presence || '/'
        uri.to_s
      end
    end
  end
end
