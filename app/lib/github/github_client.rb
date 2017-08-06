require 'graphql/client/http'

# Fake "name" method to make this look like a constant to avoid DynamicQueryError
class GraphQL::Client::OperationDefinition
  def name
    "Foobar"
  end
end

module Github
  class GithubClient
    include Singleton
    
    def initialize
      @faraday_client = Faraday::RackBuilder.new do |builder|
        builder.use Faraday::HttpCache, serializer: Marshal, shared_cache: false
        builder.use Octokit::Response::RaiseError
        builder.adapter Faraday.default_adapter
      end
      Octokit.middleware = @faraday_client

      schema_file = File.expand_path(File.join(__FILE__, '../graphql_schema.json'))
      @graphql_schema = GraphQL::Client.load_schema(schema_file)
    end

    def new_app_client
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

    def new_account_client(account)
      # TODO: Use optimal caching for access tokens
      # make them hidden, transparent and shared
      token = new_app_client.create_installation_access_token(account.ref)
      Octokit::Client.new(access_token: token[:token])
    end

    def new_repo_client(repo)
      new_account_client repo.account
    end

    def new_user_client(user)
      Octokit::Client.new(access_token: user.payload[:credentials][:token])
    end

    def new_graphql_client(api_client)
      http = GraphQL::Client::HTTP.new("https://api.github.com/graphql") do
        def headers(context)
          { "Authorization" => "Bearer #{@token}" }
        end
      end
      token = api_client.try(:bearer_token) || api_client.try(:access_token)
      http.instance_variable_set "@token", token
      GraphQL::Client.new(schema: @graphql_schema, execute: http)
    end

    def new_graphql_query(query_str)
      api_client = new_app_client
      gql_client = new_graphql_client api_client
      parsed_query = gql_client.parse(query_str)
    end
  end
end
