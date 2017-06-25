module Github
  class HomeController < BaseController
    before_action :require_login

    def index
      render :index
    end
  end
end
