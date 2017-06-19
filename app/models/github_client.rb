class GithubClient
	def self.app_client
		app_client = Octokit::Client.new(:bearer_token => new_app_token)
	end

	private

	def self.new_app_token
		private_pem = File.read(Settings.github_cert)
		private_key = OpenSSL::PKey::RSA.new(private_pem)
    payload = {}.tap do |opts|
      opts[:iat] = Time.now.to_i
      opts[:exp] = opts[:iat] + 600
      opts[:iss] = Settings.github_id
    end
    JWT.encode(payload, private_key, 'RS256')
	end
end
