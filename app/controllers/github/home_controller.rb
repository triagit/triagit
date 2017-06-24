module Github
  class HomeController < BaseController
    before_action :require_login

    def index
    end
  end
end
