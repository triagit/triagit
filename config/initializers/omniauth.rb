OmniAuth.config.logger = Rails.logger
OmniAuth.config.full_host = ENV['BASE_URL'] if ENV['BASE_URL']
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end
