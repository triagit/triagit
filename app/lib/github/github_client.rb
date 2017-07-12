module Github
  class GithubClient
    def self.new_account_client(account)
      # TODO: Use optimal caching for access tokens
      # make them hidden, transparent and shared
      token = new_app_client.create_installation_access_token(account.ref)
      Octokit::Client.new(access_token: token[:token])
    end

    def self.new_repo_client(repo)
      new_account_client repo.account
    end

    def self.new_user_client(user)
      Octokit::Client.new(access_token: user.payload[:credentials][:token])
    end

    def self.new_app_client
      private_pem = File.read(ENV['GITHUB_APP_CERT'])
      private_key = OpenSSL::PKey::RSA.new(private_pem)
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + 600,
        iss: ENV['GITHUB_APP_ID']
      }
      bearer_token = JWT.encode(payload, private_key, 'RS256')
      Octokit::Client.new(bearer_token: bearer_token)
    end
  end
end
