# frozen_string_literal: true

module LinkedRails
  class Sequence
    attr_accessor :node
    attr_writer :members
    alias read_attribute_for_serialization send

    def initialize(members, id: nil)
      self.node = id || RDF::Node.new
      self.members = members
    end

    def members
      @members = @members.respond_to?(:call) ? @members.call : @members
    end
  end
end
