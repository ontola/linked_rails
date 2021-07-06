# frozen_string_literal: true

module LinkedRails
  class MediaObjectSerializer < LinkedRails.serializer_parent_class
    include LinkedRails::Serializer
    attribute :content_url, predicate: Vocab.schema.contentUrl
    attribute :content_type, predicate: Vocab.schema.encodingFormat, datatype: Vocab.xsd.string
    attribute :description, predicate: Vocab.schema.caption
    attribute :embed_url, predicate: Vocab.schema.embedUrl
    attribute :filename, predicate: Vocab.dbo.filename
    attribute :thumbnail_url, predicate: Vocab.schema.thumbnail
    attribute :uploaded_at, predicate: Vocab.schema.uploadDate
    attribute :url, predicate: Vocab.schema.url
    attribute :cover_url, predicate: Vocab.ontola[:imgUrl1500x2000]
    attribute :position_y, predicate: Vocab.ontola[:imagePositionY]
  end
end
