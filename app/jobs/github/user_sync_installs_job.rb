module Github
  class UserSyncInstallsJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(User) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      user = args[0]
      logger.info self.class.name, user: user.id, service: user.service
      client = GithubClient.instance.new_user_client(user)
      opts = client.ensure_api_media_type(:integrations, {})
      gh_installs = client.paginate '/user/installations', opts
      gh_installs.installations.each do |gh_install|
        account = sync_gh_install client, user, gh_install
        gh_repos = client.paginate "/user/installations/#{gh_install.id}/repositories", opts
        gh_repos.repositories.each do |gh_repo|
          sync_gh_repo client, user, account, gh_repo
        end
      end
    end

    protected

    def sync_gh_install(client, user, gh_install)
      logger.info 'sync_gh_install', user: user.id, install: gh_install.id
      account = Account.find_or_initialize_by(
        service: Constants::GITHUB, ref: gh_install.id
      )
      account.name = gh_install.account.login
      account.payload = gh_install.to_h
      account.token ||= SecureRandom.uuid
      account.plan ||= Constants::PLAN_FREE_0
      account.status ||= Constants::STATUS_ACTIVE
      account.save!
      AccountUser.find_or_create_by! user: user, account: account
      account
    end

    def sync_gh_repo(client, user, account, gh_repo)
      # TODO: Handle repository renames
      logger.info 'sync_gh_repo', user: user.id, account: account.ref, repo: gh_repo.full_name
      repo = Repo.find_or_initialize_by(
        service: Constants::GITHUB, account: account, ref: gh_repo.full_name
      )

      begin
        rules = load_rules(repo)
      rescue => e
        logger.error 'Invalid triagit.yaml', repo: gh_repo.full_name
        return
      end

      repo.name = gh_repo.full_name
      repo.ref = gh_repo.full_name
      repo.payload = gh_repo.to_h
      repo.status ||= Constants::STATUS_ACTIVE
      repo.rules = rules
      repo.save!
      repo
    end

    def load_rules(repo)
      client = GithubClient.instance.new_repo_client(repo)
      yaml_file = client.contents(repo.ref, path: 'triagit.yaml')
      yaml = YAML.load Base64.decode64(yaml_file.content)
    end
  end
end
