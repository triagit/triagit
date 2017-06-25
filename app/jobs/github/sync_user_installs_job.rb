class Github::SyncUserInstallsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    unless args.present? and args[0].is_a?(User) and args[0].service == Service::GITHUB
      return logger.error 'Invalid argument passed', args: args
    end
    user = args[0]
    client = Github::Client.new_user_client(user)
    opts = client.ensure_api_media_type(:integrations, {})
    res_installs = client.paginate "/user/installations", opts
    res_installs.installations.each do |install|
      res_repos = client.paginate "/user/installations/#{install.id}/repositories", opts
      logger.info "Got repos", repos: res_repos
    end
  end
end
