module Hashable
  extend ActiveSupport::Concern

  def encoded_id
    return if id.nil?

    Hashable.hashids.encode(id)
  end

  def self.hashids
    Hashids.new(RadicalConfig.hash_key!, 6, RadicalConfig.hash_alphabet!)
  end

  class_methods do
    def find_decoded(encoded_id)
      ids = Hashable.hashids.decode(encoded_id)
      find(ids[0]) if ids && ids.count == 1 && ids[0]
    end
  end
end
