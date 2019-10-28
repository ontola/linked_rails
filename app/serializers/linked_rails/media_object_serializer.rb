# frozen_string_literal: true

module LinkedRails
  class MediaObjectSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer
    attribute :content_url, predicate: RDF::Vocab::SCHEMA.contentUrl
    attribute :content_type, predicate: RDF::Vocab::SCHEMA.encodingFormat, datatype: RDF::XSD[:string]
    attribute :description, predicate: RDF::Vocab::SCHEMA.caption
    attribute :embed_url, predicate: RDF::Vocab::SCHEMA.embedUrl
    attribute :filename, predicate: RDF::Vocab::DBO.filename
    attribute :thumbnail_url, predicate: RDF::Vocab::SCHEMA.thumbnail
    attribute :uploaded_at, predicate: RDF::Vocab::SCHEMA.uploadDate
    attribute :url, predicate: RDF::Vocab::SCHEMA.url
    attribute :cover_url, predicate: Vocab::ONTOLA[:imgUrl1500x2000]
    attribute :position_y, predicate: Vocab::ONTOLA[:imagePositionY]

    def type
      case object.type&.to_sym
      when :image
        RDF::Vocab::SCHEMA.ImageObject
      when :video
        RDF::Vocab::SCHEMA.VideoObject
      else
        RDF::Vocab::SCHEMA.MediaObject
      end
    end
  end
end
