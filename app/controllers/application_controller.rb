class ApplicationController < ActionController::Base
  require 'coinbase/wallet'

  protect_from_forgery with: :exception
  rescue_from Coinbase::Wallet::ServiceUnavailableError, with: :coinbase_is_down
  rescue_from Coinbase::Wallet::APIError, with: :coinbase_api_error

  def coinbase_is_down(exception)
    render json: { coinbase: 'down', message: exception.message }
  end

  def coinbase_api_error(exception)
    render json: { coinbase: 'api_error', message: exception.message }
  end

  protected

  def logged?
    session[:password] == ENV['PASSWORD']
  end

  def login
    redirect_to '/sessions/new' unless logged?
  end
end
