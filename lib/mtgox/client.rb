require 'faraday/error'
require 'mtgox/ask'
require 'mtgox/balance'
require 'mtgox/bid'
require 'mtgox/buy'
require 'mtgox/connection'
require 'mtgox/max_bid'
require 'mtgox/min_ask'
require 'mtgox/request'
require 'mtgox/sell'
require 'mtgox/ticker'
require 'mtgox/trade'

module MtGox
  class Client
    include MtGox::Connection
    include MtGox::Request

    ORDER_TYPES = {:sell => 1, :buy => 2}

    # Fetch the latest ticker data
    #
    # @authenticated false
    # @return [MtGox::Ticker]
    # @example
    #   MtGox.ticker
    def ticker
      ticker = get("/api/1/BTC#{MtGox.currency}/public/ticker")['return']
      Ticker.instance.buy    = ticker['buy']['value'].to_f
      Ticker.instance.high   = ticker['high']['value'].to_f
      Ticker.instance.price  = ticker['last']['value'].to_f
      Ticker.instance.low    = ticker['low']['value'].to_f
      Ticker.instance.sell   = ticker['sell']['value'].to_f
      Ticker.instance.volume = ticker['vol']['value'].to_f
      Ticker.instance
    end

    # Fetch both bids and asks in one call, for network efficiency
    #
    # @authenticated false
    # @return [Hash] with keys :asks and :bids, which contain arrays as described in {MtGox::Client#asks} and {MtGox::Clients#bids}
    # @example
    #   MtGox.offers
    def offers
      offers = get("/api/1/BTC#{MtGox.currency}/public/depth?raw")
      asks = offers['asks'].sort_by do |ask|
        ask[0].to_f
      end.map! do |ask|
        Ask.new(ask)
      end
      bids = offers['bids'].sort_by do |bid|
        -bid[0].to_f
      end.map! do |bid|
        Bid.new(bid)
      end
      {:asks => asks, :bids => bids}
    end

    # Fetch open asks
    #
    # @authenticated false
    # @return [Array<MtGox::Ask>] an array of open asks, sorted in price ascending order
    # @example
    #   MtGox.asks
    def asks
      offers[:asks]
    end

    # Fetch open bids
    #
    # @authenticated false
    # @return [Array<MtGox::Bid>] an array of open bids, sorted in price descending order
    # @example
    #   MtGox.bids
    def bids
      offers[:bids]
    end

    # Fetch the lowest priced ask
    #
    # @authenticated false
    # @return [MtGox::MinAsk]
    # @example
    #   MtGox.min_ask
    def min_ask
      min_ask = asks.first
      MinAsk.instance.price = min_ask.price
      MinAsk.instance.amount = min_ask.amount
      MinAsk.instance
    end

    # Fetch the highest priced bid
    #
    # @authenticated false
    # @return [MtGox::MinBid]
    # @example
    #   MtGox.max_bid
    def max_bid
      max_bid = bids.first
      MaxBid.instance.price = max_bid.price
      MaxBid.instance.amount = max_bid.amount
      MaxBid.instance
    end

    # Fetch recent trades
    #
    # @authenticated false
    # @param arg Get all trades since this trade. May be a Trade object or an integer (Trade#id). If nil, will fetch all trades.
    # @return [Array<MtGox::Trade>] an array of trades, sorted in chronological order
    # @example
    #   MtGox.trades
    def trades(arg=nil)
      since = case arg
	when NilClass
	  {}
	when Trade
	  {:since => arg.id}
	when Numeric
	  {:since => arg}
	else
	  raise Exception.new("Invalid argument, #{arg.class}")
      end 

      get("/api/1/BTC#{MtGox.currency}/public/trades?raw", since).sort_by{|trade| trade['date']}.map do |trade|
        Trade.new(trade)
      end
    end

    # Fetch your current balance
    #
    # @authenticated true
    # @return [Array<MtGox::Balance>]
    # @example
    #   MtGox.balance
    def balance
      # TODO: This will return balance only in USD.. Currently no way to do EUR?
      parse_balance(post('/code/getFunds.php', pass_params))
    end

    # Fetch your open orders, both buys and sells, for network efficiency
    #
    # @authenticated true
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   MtGox.orders
    def orders
      parse_orders(post('/code/getOrders.php', pass_params)['orders'])
    end

    # Fetch your open buys
    #
    # @authenticated true
    # @return [Array<MtGox::Buy>] an array of your open bids, sorted by date
    # @example
    #   MtGox.buys
    def buys
      orders[:buys]
    end

    # Fetch your open sells
    #
    # @authenticated true
    # @return [Array<MtGox::Sell>] an array of your open asks, sorted by date
    # @example
    #   MtGox.sells
    def sells
      orders[:sells]
    end

    # Place a limit order to buy BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to purchase
    # @param price [Numeric] the bid price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Buy one bitcoin for $0.011
    #   MtGox.buy! 1.0, 0.011
    def buy!(amount, price)
      parse_orders(post('/code/buyBTC.php', pass_params.merge({:amount => amount, :price => price}))['orders'])
    end

    # Place a limit order to sell BTC
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to sell
    # @param price [Numeric] the ask price in US dollars
    # @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    # @example
    #   # Sell one bitcoin for $100
    #   MtGox.sell! 1.0, 100.0
    def sell!(amount, price)
      parse_orders(post('/code/sellBTC.php', pass_params.merge({:amount => amount, :price => price}))['orders'])
    end

    # Cancel an open order
    #
    # @authenticated true
    # @overload cancel(oid)
    #   @param oid [String] an order ID
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order.oid
    #     MtGox.cancel 1234567890
    # @overload cancel(order)
    #   @param order [Hash] a hash-like object, with keys `oid` - the order ID of the transaction to cancel and `type` - the type of order to cancel (`1` for sell or `2` for buy)
    #   @return [Hash] with keys :buys and :sells, which contain arrays as described in {MtGox::Client#buys} and {MtGox::Clients#sells}
    #   @example
    #     my_order = MtGox.orders.first
    #     MtGox.cancel my_order
    #     MtGox.cancel {'oid' => '1234567890', 'type' => 2}
    # This appears to be all wrong? Firstly, orders are not Hash objects, and secondly, they don't have OID, but ID // Mikael Wikman
    #def cancel(args)
    #  if args.is_a?(Hash)
    #    order = args.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
    #    parse_orders(post('/code/cancelOrder.php', pass_params.merge(order))['orders'])
    #  else
    #    orders = post('/code/getOrders.php', pass_params)['orders']
    #    order = orders.find{|order| order['oid'] == args.to_s}
    #    if order
    #      order = order.delete_if{|k, v| !['oid', 'type'].include?(k.to_s)}
    #      parse_orders(post('/code/cancelOrder.php', pass_params.merge(order))['orders'])
    #    else
    #      raise Faraday::Error::ResourceNotFound, {:status => 404, :headers => {}, :body => 'Order not found.'}
    #    end
    #  end
    #end

    # Added by Mikael Wikman (will document it later)
    def cancel(arg)
      (oid = arg.is_a?(Order) ? arg.id : id).kind_of?(String) or raise("Could not find valid order id")
      parse_orders(post('/code/cancelOrder.php', pass_params.merge({:oid => oid}))['orders'])
    end

    # Transfer bitcoins from your Mt. Gox account into another account
    #
    # @authenticated true
    # @param amount [Numeric] the number of bitcoins to withdraw
    # @param btca [String] the bitcoin address to send to
    # @return [Array<MtGox::Balance>]
    # @example
    #   # Withdraw 1 BTC from your account
    #   MtGox.withdraw! 1.0, '1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L'
    def withdraw!(amount, btca)
      parse_balance(post('/code/withdraw.php', pass_params.merge({:group1 => 'BTC', :amount => amount, :btca => btca})))
    end

    private

    def parse_balance(balance)
      balances = []
      balances << Balance.new('BTC', balance['btcs'])
      balances << Balance.new(MtGox.currency, balance[MtGox.currency.downcase+'s'])
      balances
    end

    def parse_orders(orders)
      buys = []
      sells = []
      orders.sort_by{|order| order['date']}.each do |order|
        case order['type']
        when ORDER_TYPES[:sell]
          sells << Sell.new(order)
        when ORDER_TYPES[:buy]
          buys << Buy.new(order)
        end
      end
      {:buys => buys, :sells => sells}
    end

    def pass_params
      {:name => MtGox.username, :pass => MtGox.password}
    end
  end
end
