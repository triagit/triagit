module Github
  class SessionsController < BaseController
    def new
      auth_hash = request.env['omniauth.auth']
      user = User.find_or_initialize_by(service: Constants::GITHUB, ref: auth_hash['uid'])
      user.name = auth_hash['info']['nickname']
      user.payload = auth_hash.to_hash
      user.save!

      Github::SyncUserInstallsJob.perform_later user

      session[:uid] = user.id
      redirect_to github_root_url
    end
  end
end
