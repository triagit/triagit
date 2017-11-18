module Github
  class RepoSyncJob < ApplicationJob
    queue_as :default

    DEFAULT_RULES = [
      {:name => "sync_triagit", :rule => "sync_triagit"}
    ]

    WEBHOOK_EVENT_NAME = 'push'

    def perform(*args)
      unless args.present? && args[0].is_a?(Repo) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end

      if args[1].present? && args[1].is_a?(Event)
        return unless valid?(args[1])
      end

      begin
        repo = args[0]
        logger.info self.class.name, repo: repo.name
        repo.rules = load_rules(repo)
        repo.updated_at = DateTime.now
        repo.save!
      rescue => e
        logger.error 'Invalid triagit.yaml', repo: repo.name
        logger.error e
        return
      end
    end

    private

    def valid?(event)
      return event.name == WEBHOOK_EVENT_NAME &&
        event.payload[:commits].any? { |c| c[:added].include?(".github/triagit.yaml") ||
          c[:modified].include?(".github/triagit.yaml") }
    end

    def load_rules(repo)
      client = GithubClient.instance.new_repo_client(repo)
      yaml_file = client.contents(repo.ref, path: '.github/triagit.yaml')
      yaml = YAML.load Base64.decode64(yaml_file.content)
      yaml.deep_symbolize_keys!
      add_default_rules(yaml)
    end

    def add_default_rules(yaml)
      yaml[:rules] = yaml[:rules] + DEFAULT_RULES
      yaml
    end
  end
end
