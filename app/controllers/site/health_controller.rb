module Site
  class HealthController < BaseController
    def show
      app_client = Github::GithubClient.instance.new_app_client
      begin
        app_client.find_app_installations()
      rescue => e
        logger.error 'Connection to Github failed'
        return render json: {"status": "Connection to Github failed"}, status: 500
      end
      render json: {status: "OK"}, status: 200
    end
  end
end
