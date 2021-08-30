# frozen_string_literal: true

require_relative '../../lib/vocab'

LinkedRails.host = raise('Enter your host. Use an ENV var if you have multiple environments')
LinkedRails.scheme = :https

LinkedRails::Renderers.register!
