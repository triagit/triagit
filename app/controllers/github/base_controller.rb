module Github
  class BaseController < ::ApplicationController
    layout '../github/shared/layout'
    helper 'github/github'
    helper_method :current_user

    protected

    def require_login
      return if session[:uid].present? && current_user.present?
      redirect_to '/auth/github'
    end

    def current_user
      @current_user ||= User.find session[:uid]
    end
  end
end
