require 'mtgox/offer'

module MtGox
  class Bid < Offer

    def initialize(bid)
      self.price = bid['price'].to_f
      self.amount = bid['amount'].to_f
    end

    def eprice
      price * (1 - MtGox.commission)
    end

  end
end
