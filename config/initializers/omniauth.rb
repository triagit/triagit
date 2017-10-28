OmniAuth.config.logger = Rails.logger
OmniAuth.config.full_host = ENV['SITE_FQDN'] if ENV['SITE_FQDN']
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['GITHUB_CLIENT_ID'], ENV['GITHUB_CLIENT_SECRET']
end
