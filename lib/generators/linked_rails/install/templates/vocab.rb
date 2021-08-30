# frozen_string_literal: true

class Vocab < LinkedRails::Vocab
  register(:example, 'https://example.com/my_vocab#')
  app_vocabulary :example
end
