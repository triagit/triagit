class ApplicationController < ActionController::Base

  def current_user
    @current_user ||= User.find session[:uid]
  end

end
