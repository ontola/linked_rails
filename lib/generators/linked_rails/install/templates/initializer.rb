# frozen_string_literal: true

require_relative '../../lib/vocab'

LinkedRails.host = 'example.com'
LinkedRails.scheme = :https
LinkedRails.app_vocab = Vocab.example

LinkedRails::Renderers.register!
