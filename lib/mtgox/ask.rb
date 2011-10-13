require 'mtgox/offer'

module MtGox
  class Ask < Offer

    def initialize(ask)
      self.price = ask['price'].to_f
      self.amount = ask['amount'].to_f
    end

    def eprice
      price / (1 - MtGox.commission)
    end

  end
end
