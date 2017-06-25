module Github
  class SyncUserInstallsJob < ApplicationJob
    queue_as :default

    def perform(*args)
      unless args.present? && args[0].is_a?(User) && args[0].service == Constants::GITHUB
        return logger.error 'Invalid argument passed', args: args
      end
      user = args[0]
      client = GithubClient.new_user_client(user)
      opts = client.ensure_api_media_type(:integrations, {})
      gh_installs = client.paginate '/user/installations', opts
      gh_installs.installations.each do |gh_install|
        account = sync_gh_install user, gh_install
        gh_repos = client.paginate "/user/installations/#{gh_install.id}/repositories", opts
        gh_repos.repositories.each do |gh_repo|
          sync_gh_repo user, account, gh_repo
        end
      end
    end

    protected

    def sync_gh_install(user, gh_install)
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

    def sync_gh_repo(_user, account, gh_repo)
      repo = Repo.find_or_initialize_by(
        service: Constants::GITHUB, account: account, ref: gh_repo.id
      )
      repo.name = gh_repo.full_name
      repo.payload = gh_repo.to_h
      repo.status ||= Constants::STATUS_ACTIVE
      repo.save!
      repo
    end
  end
end
