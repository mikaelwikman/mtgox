require 'mtgox/offer'

module MtGox
  class Order < Offer
    attr_accessor :id, :date

    def initialize(order={})
      self.id     = order['oid']
      self.date   = Time.at(order['date'].to_i)
      self.amount = order['amount'].to_f
      self.price  = order['price'].to_f
      self.price_currency = MtGox.currency  # the MtGox API will implicitly return your orders in your main currency
    end
  end
end
