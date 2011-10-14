# Ruby wrapper for the Mt. Gox Trade API
Mt. Gox allows you to trade traditional currencies for Bitcoins (BTC) and Bitcoins for traditional currencies.

## <a name="installation">Installation</a>
    gem install mtgox

## <a name="alias">Alias</a>
After installing the gem, you can get the current price for 1 BTC in USD by
typing `btc` in your bash shell simply by setting the following alias:

    alias btc='ruby -r rubygems -r mtgox -e "puts MtGox.ticker.sell"'

## <a name="documentation">Documentation</a>
[http://rdoc.info/gems/mtgox](http://rdoc.info/gems/mtgox)

## <a name="donate">Donate</a>
If you find this library useful, please consider sending a donation to the
author, which you can do using the following script:

    require 'rubygems'
    require 'mtgox'

    # Certain methods require authentication
    MtGox.configure do |config|
      config.username = YOUR_MTGOX_USERNAME
      config.password = YOUR_MTGOX_PASSWORD
    end

    MtGox.withdraw 1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"

## <a name="ci">Continuous Integration</a>
[![Build Status](https://secure.travis-ci.org/sferik/mtgox.png)](http://travis-ci.org/sferik/mtgox)

## <a name="examples">Usage Examples</a>
    require 'rubygems'
    require 'mtgox'

    MtGox.configure do |config|
      config.currency = "USD"
    end

    # Fetch the latest price for 1 BTC in USD
    puts MtGox.ticker.sell

    # Fetch open asks
    puts MtGox.asks

    # Fetch open bids
    puts MtGox.bids

    # Fetch the last 48 hours worth of trades (takes a minute)
    puts MtGox.trades

    # Certain methods require authentication
    MtGox.configure do |config|
      config.username = YOUR_MTGOX_USERNAME
      config.password = YOUR_MTGOX_PASSWORD
    end

    # Fetch the current balance of each wallet
    puts MtGox.balance

    # Place a limit order to buy one bitcoin for $0.011
    MtGox.buy! 1.0, 0.011

    # Place a limit order to sell one bitcoin for $100
    MtGox.sell! 1.0, 100.0

    # Cancel order #1234567890
    MtGox.cancel 1234567890

    # Withdraw 1 BTC from your account
    MtGox.withdraw! 1.0, "1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L"

## <a name="contributing">Contributing</a>
In the spirit of [free
software](http://www.fsf.org/licensing/essays/free-sw.html), **everyone** is
encouraged to help improve this project.

Here are some ways *you* can contribute:

* by using alpha, beta, and prerelease versions
* by reporting bugs
* by suggesting new features
* by writing or editing documentation
* by writing specifications
* by writing code (**no patch is too small**: fix typos, add comments, clean up
  inconsistent whitespace)
* by refactoring code
* by closing [issues](https://github.com/sferik/mtgox/issues)
* by reviewing patches
* by financially (please send bitcoin donations to
  1KxSo9bGBfPVFEtWNLpnUK1bfLNNT4q31L)

## <a name="issues">Submitting an Issue</a>
We use the [GitHub issue tracker](https://github.com/sferik/mtgox/issues) to
track bugs and features. Before submitting a bug report or feature request,
check to make sure it hasn't already been submitted. You can indicate support
for an existing issuse by voting it up. When submitting a bug report, please
include a [Gist](https://gist.github.com/) that includes a stack trace and any
details that may be necessary to reproduce the bug, including your gem version,
Ruby version, and operating system. Ideally, a bug report should include a pull
request with failing specs.

## <a name="pulls">Submitting a Pull Request</a>
1. Fork the project.
2. Create a topic branch.
3. Implement your feature or bug fix.
4. Add documentation for your feature or bug fix.
5. Run <tt>bundle exec rake doc:yard</tt>. If your changes are not 100%
   documented, go back to step 4.
6. Add specs for your feature or bug fix.
7. Run <tt>bundle exec rake spec</tt>. If your changes are not 100% covered, go
   back to step 6.
8. Commit and push your changes.
9. Submit a pull request. Please do not include changes to the gemspec,
   version, or history file. (If you want to create your own version for some
   reason, please do so in a separate commit.)

## <a name="rubies">Supported Rubies</a>
This library aims to support and is [tested
against](http://travis-ci.org/sferik/mtgox) the following Ruby implementations:

* Ruby 1.8.7
* Ruby 1.9.1
* Ruby 1.9.2
* [JRuby](http://www.jruby.org/)
* [Rubinius](http://rubini.us/)
* [Ruby Enterprise Edition](http://www.rubyenterpriseedition.com/)

If something doesn't work on one of these interpreters, it should be considered
a bug.

This library may inadvertently work (or seem to work) on other Ruby
implementations, however support will only be provided for the versions listed
above.

If you would like this library to support another Ruby version, you may
volunteer to be a maintainer. Being a maintainer entails making sure all tests
run and pass on that implementation. When something breaks on your
implementation, you will be personally responsible for providing patches in a
timely fashion. If critical issues for a particular implementation exist at the
time of a major release, support for that Ruby version may be dropped.

## <a name="copyright">Copyright</a>
Copyright (c) 2011 Erik Michaels-Ober.
See [LICENSE](https://github.com/sferik/mtgox/blob/master/LICENSE.md) for details.
