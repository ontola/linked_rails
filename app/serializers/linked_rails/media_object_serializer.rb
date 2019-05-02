# frozen_string_literal: true

module LinkedRails
  class MediaObjectSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer
    attribute :content_url, predicate: NS::SCHEMA[:contentUrl]
    attribute :content_type, predicate: NS::SCHEMA[:encodingFormat], datatype: RDF::XSD[:string]
    attribute :description, predicate: NS::SCHEMA[:caption]
    attribute :embed_url, predicate: NS::SCHEMA[:embedUrl]
    attribute :filename, predicate: NS::DBO[:filename]
    attribute :thumbnail_url, predicate: NS::SCHEMA[:thumbnail]
    attribute :uploaded_at, predicate: NS::SCHEMA[:uploadDate]
    attribute :url, predicate: NS::SCHEMA[:url]

    def type
      case object.type&.to_sym
      when :image
        NS::SCHEMA[:ImageObject]
      when :video
        NS::SCHEMA[:VideoObject]
      else
        NS::SCHEMA[:MediaObject]
      end
    end
  end
end
