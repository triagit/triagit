module Site
  class HealthController < BaseController
    def show
      begin
        Github::GithubClient.instance.new_app_client.find_app_installations
        render json: {status: "OK"}, status: 200
      rescue => e
        logger.error 'Connection to Github failed', e
        render json: {status: "Connection to Github failed"}, status: 500
      end
    end
  end
end
