module Github
  class BaseController < ::ApplicationController
    layout '../github/shared/layout'
    helper 'github/github'
    helper_method :current_user

    protected

    def require_login
      unless session[:uid].present? and current_user.present?
        redirect_to '/auth/github'
      end
    end

    def current_user
      @current_user ||= User.find session[:uid]
    end
  end
end
