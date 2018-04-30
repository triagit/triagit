class ApplicationController < ActionController::Base

  def current_user
    @current_user ||= User.find session[:uid]
  end

  def authenticate_admin_user!
    if not current_user && current_user.superadmin?
      return redirect_to '/logout'
    end
  end

end
