class CoinbaseService
  require 'coinbase/wallet'

  attr_reader :client

  def initialize
    @client = Coinbase::Wallet::Client.new(api_key: ENV['COINBASE_API_KEY'], api_secret: ENV['COINBASE_API_SECRET'])
  end

  def stats
    Stat.create(balance: total_balance, profit: profit, percentage: profit_percentage, saved_date: Time.zone.now)

    {
      deposits: total_deposited,
      btc_balance: btc_balance,
      eth_balance: eth_balance,
      balance: total_balance,
      profit: profit.round(3),
      profit_percentage: profit_percentage.round(3)
    }
  end

  private

  def total_deposited
    total = 0
    client.transactions(eur_account.id) do |data, _resp|
      deposits = data.reject { |t| t.type == 'buy' }
      total += deposits.map { |deposit| deposit.amount['amount'] }.map(&:to_f).inject(:+)
    end

    total
  end

  def profit
    @profit ||= total_balance - total_deposited
  end

  def profit_percentage
    @profit_percentage ||= (profit / total_deposited) * 100.0
  end

  def total_balance
    @total_balance ||= btc_balance + eth_balance
  end

  def btc_balance
    @btc ||= balance(btc_account)
  end

  def eth_balance
    @eth ||= balance(eth_account)
  end

  def balance(account)
    account.native_balance['amount'].to_f
  end

  def btc_account
    wallet('BTC Wallet')
  end

  def eth_account
    wallet('ETH Wallet')
  end

  def eur_account
    wallet('EUR Wallet')
  end

  def wallet(name)
    client.accounts.find { |a| a.name == name }
  end
end