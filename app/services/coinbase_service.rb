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
      ltc_balance: ltc_balance,
      bought_btc: deposited_wallet(btc_account),
      bought_eth: deposited_wallet(eth_account),
      bought_ltc: deposited_wallet(ltc_account),
      balance: total_balance,
      profit: profit.round(3),
      profit_percentage: profit_percentage.round(2)
    }
  end

  def sell(amount, coin)
    wl = send("#{coin}_account")
    wl.sell(amount: amount.to_f.round(2), currency: 'EUR')
  end

  private

  def total_deposited
    total = 0
    client.transactions(eur_account.id) do |data, _resp|
      deposits = data.select { |t| t.type == 'fiat_deposit' }
      total += deposits.map { |deposit| deposit.native_amount['amount'] }.map(&:to_f).inject(:+)
    end

    total
  end

  def profit
    @profit ||= total_balance - total_deposited
  end

  def deposited_wallet(wallet)
    total = 0
    return total if wallet.transactions.empty?
    wallet.transactions do |data, _resp|
      deposits = data.select { |t| t.type == 'buy' }
      total += deposits.map { |deposit| deposit.native_amount['amount'] }.map(&:to_f).inject(:+)
    end
    total
  end

  def profit_percentage
    @profit_percentage ||= (profit / total_deposited) * 100.0
  end

  def total_balance
    @total_balance ||= btc_balance + eth_balance + eur_balance + ltc_balance
  end

  def btc_balance
    @btc ||= balance(btc_account)
  end

  def eth_balance
    @eth ||= balance(eth_account)
  end

  def ltc_balance
    @ltc ||= balance(ltc_account)
  end

  def eur_balance
    @eur ||= balance(eur_account)
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

  def ltc_account
    wallet('LTC Wallet')
  end

  def eur_account
    wallet('EUR Wallet')
  end

  def wallet(name)
    client.accounts.find { |a| a.name == name }
  end
end
