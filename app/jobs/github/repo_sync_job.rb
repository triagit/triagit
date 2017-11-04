module Github
  class RepoSyncJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end

      begin
        repo = args[0]
        logger.info self.class.name, repo: repo.name
        repo.rules = load_rules(repo)
        repo.updated_at = DateTime.now
        repo.save!
      rescue => e
        logger.error 'Invalid triagit.yaml', repo: gh_repo.full_name
        return
      end
    end

    private

    def load_rules(repo)
      client = GithubClient.instance.new_repo_client(repo)
      yaml_file = client.contents(repo.ref, path: '.github/triagit.yaml')
      yaml = YAML.load Base64.decode64(yaml_file.content)
      yaml.deep_symbolize_keys!
      yaml
    end
  end
end
