class SessionsController < ApplicationController
  def create
    session[:password] = password
    redirect_to root_path
  end

  def password
    params[:session][:password]
  end
end
