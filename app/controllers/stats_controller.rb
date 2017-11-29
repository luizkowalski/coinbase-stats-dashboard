class StatsController < ApplicationController
  def index
    @stats = Rails.cache.fetch('stats', expires_in: 1.minute) { CoinbaseService.new.stats }
    @graph = Stat.last(30).map(&:percentage)
  end
end
