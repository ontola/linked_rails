# frozen_string_literal: true

module LinkedRails
  class MediaObject < Resource
    attr_accessor :content_type, :description, :filename, :position_y, :uploaded_at
    attr_writer :type

    %i[content_url embed_url thumbnail_url url cover_url].each do |attr|
      attr_reader attr

      define_method "#{attr}=" do |value|
        instance_variable_set("@#{attr}", value.is_a?(RDF::URI) ? value : RDF::URI(value))
      end
    end

    def rdf_type
      case type&.to_sym
      when :image
        Vocab.schema.ImageObject
      when :video
        Vocab.schema.VideoObject
      else
        Vocab.schema.MediaObject
      end
    end

    def type
      @type ||= content_type&.split('/')&.first
    end
  end
end
