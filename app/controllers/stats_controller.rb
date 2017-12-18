class StatsController < ApplicationController
  before_action :login

  def index
    @stats = Rails.cache.fetch('stats', expires_in: 1.minutes) { CoinbaseService.new.stats }
    @graph = Stat.last(30).map(&:percentage)
  end

  def cashout
    CoinbaseService.new.sell(params[:amount], params[:coin])
  end
end
