module Site
  class HomeController < BaseController
    def index
      render :index
    end

    def destroy
      session.clear
      reset_session
      redirect_to root_url
    end
  end
end
